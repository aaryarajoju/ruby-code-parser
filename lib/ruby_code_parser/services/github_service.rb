require 'octokit'
require 'open-uri'
require 'fileutils'

class RubyCodeParser
  module Services
    # GitHubService encapsulates all GitHub API interactions
    # Handles PR fetching, diff parsing, and file downloads
    class GitHubService
      attr_reader :client

      class PullRequestNotFound < StandardError; end
      class RateLimitExceeded < StandardError; end
      class AuthenticationError < StandardError; end

      # Represents a file changed in a pull request
      FileChange = Struct.new(
        :filename,
        :status,      # added, removed, modified, renamed
        :additions,
        :deletions,
        :patch,       # unified diff content
        :raw_url,
        :blob_url,
        :sha,
        keyword_init: true
      ) do
        def ruby_file?
          filename.end_with?('.rb')
        end

        def added?
          status == 'added'
        end

        def removed?
          status == 'removed'
        end

        def modified?
          status == 'modified'
        end
      end

      # Represents a pull request with its metadata
      PullRequestInfo = Struct.new(
        :repo,
        :number,
        :title,
        :description,
        :author,
        :base_branch,
        :head_branch,
        :state,
        :merged,
        :file_changes,
        :url,
        keyword_init: true
      ) do
        def ruby_files
          file_changes.select(&:ruby_file?)
        end

        def added_files
          file_changes.select(&:added?)
        end

        def modified_files
          file_changes.select(&:modified?)
        end

        def removed_files
          file_changes.select(&:removed?)
        end
      end

      def initialize(access_token: nil)
        @access_token = access_token || ENV['GITHUB_TOKEN']
        @client = build_client
      end

      # Fetches PR info including all file changes
      # @param repo [String] Repository in "owner/repo" format
      # @param pr_number [Integer] Pull request number
      # @return [PullRequestInfo]
      def fetch_pull_request(repo:, pr_number:)
        pr = @client.pull_request(repo, pr_number)
        files = @client.pull_request_files(repo, pr_number)

        file_changes = files.map do |file|
          FileChange.new(
            filename: file.filename,
            status: file.status,
            additions: file.additions,
            deletions: file.deletions,
            patch: file.patch,
            raw_url: file.raw_url,
            blob_url: file.blob_url,
            sha: file.sha
          )
        end

        PullRequestInfo.new(
          repo: repo,
          number: pr_number,
          title: pr.title,
          description: pr.body,
          author: pr.user.login,
          base_branch: pr.base.ref,
          head_branch: pr.head.ref,
          state: pr.state,
          merged: pr.merged,
          file_changes: file_changes,
          url: pr.html_url
        )
      rescue Octokit::NotFound
        raise PullRequestNotFound, "PR ##{pr_number} not found in #{repo}"
      rescue Octokit::TooManyRequests
        raise RateLimitExceeded, "GitHub API rate limit exceeded"
      rescue Octokit::Unauthorized
        raise AuthenticationError, "Invalid or missing GitHub token"
      end

      # Downloads a file from GitHub to a local path
      # @param raw_url [String] Raw file URL
      # @param local_path [String] Local destination path
      # @return [String] The local file path
      def download_file(raw_url:, local_path:)
        FileUtils.mkdir_p(File.dirname(local_path))

        File.open(local_path, "wb") do |saved_file|
          options = {}
          options["Authorization"] = "token #{@access_token}" if @access_token
          URI.open(raw_url, **options) do |read_file|
            saved_file.write(read_file.read)
          end
        end

        local_path
      rescue OpenURI::HTTPError => e
        raise "Failed to download #{raw_url}: #{e.message}"
      end

      # Parses a PR URL and extracts repo and PR number
      # @param url [String] GitHub PR URL
      # @return [Hash] { repo: "owner/repo", pr_number: 123 }
      def self.parse_pr_url(url)
        match = url.match(%r{github\.com/([\w-]+/[\w-]+)/pull/(\d+)})
        return nil unless match

        {
          repo: match[1],
          pr_number: match[2].to_i
        }
      end

      # Extracts all PR URLs from text
      # @param text [String] Text containing PR URLs
      # @return [Array<Hash>] Array of parsed PR info
      def self.extract_pr_urls(text)
        text.to_s.scan(%r{https?://github\.com/[\w-]+/[\w-]+/pull/\d+}).map do |url|
          parse_pr_url(url)
        end.compact
      end

      private

      def build_client
        options = { auto_paginate: true }
        options[:access_token] = @access_token if @access_token
        Octokit::Client.new(options)
      end
    end
  end
end

