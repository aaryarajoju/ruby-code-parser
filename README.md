# Ruby Code Parser - Design Principles Analyzer

A modular static analysis pipeline for Ruby codebases that detects violations of software design principles (SOLID, DRY, Law of Demeter, Information Expert, and more).

## Features

- **Pull Request Analysis**: Analyze GitHub PRs with diff-aware context
- **Multi-Principle Detection**: 10 built-in detectors for common design principles
- **Rich Reports**: JSON, Markdown, and HTML output formats
- **LLM-Ready**: Architecture prepared for LLM-based analysis integration
- **Configurable**: Tune thresholds and enable/disable detectors
- **Batch Processing**: Process multiple PRs from CSV files

## Detected Principles

| Principle | Description |
|-----------|-------------|
| **SRP** | Single Responsibility - Classes doing too much |
| **OCP** | Open/Closed - Type-checking conditionals |
| **LSP** | Liskov Substitution - Method signature mismatches |
| **DIP** | Dependency Inversion - Direct concrete instantiations |
| **ISP** | Interface Segregation - Overly large module interfaces |
| **Law of Demeter** | Long method chains (train wrecks) |
| **DRY** | Don't Repeat Yourself - Duplicate implementations |
| **Information Expert** | Methods manipulating external state |
| **Encapsulation** | Excessive public exposure |
| **Class Methods** | Overuse of class-level methods |

## Installation

```bash
# Clone the repository
git clone <repo-url>
cd ruby-code-parser-work

# Install dependencies
bundle install

# Set up GitHub token (for PR analysis)
export GITHUB_TOKEN="your_github_token"
```

## Quick Start

### Analyze a Single File

```bash
bundle exec ruby ./bin/run_analysis path/to/file.rb
```

### Analyze a Pull Request

```bash
./bin/analyze_pr https://github.com/org/repo/pull/123
```

### Batch Process PRs from CSV

```bash
# Analyze all PRs in the CSV
./bin/analyze_pr --csv submissions.csv

# Filter to specific rows
./bin/analyze_pr --csv submissions.csv --filter "E2541"
```

## CLI Options

```
Usage: analyze_pr [options] [PR_URL]

Options:
    --csv FILE        Read PR URLs from CSV file
    --column COL      CSV column containing PR links (default: links)
    --filter TERM     Only process rows containing this term
    --output DIR      Output directory for reports (default: reports)
    --format FORMATS  Output formats: json,md,html (comma-separated)
    --config FILE     Config file path (YAML or JSON)
    --[no-]verbose    Enable verbose output
    -h, --help        Show help
```

## Programmatic Usage

```ruby
require 'ruby_code_parser'

# Analyze files directly
violations = RubyCodeParser.analyze("app/models/user.rb")

# Analyze a PR
result = RubyCodeParser.analyze_pr("https://github.com/org/repo/pull/123")

# Analyze PR with automatic report generation
RubyCodeParser.analyze_pr_with_report(
  "https://github.com/org/repo/pull/123",
  output_dir: "my_reports"
)

# Access analysis results
puts "Found #{result.violations.count} violations"
result.summary[:violations_by_type].each do |type, count|
  puts "  #{type}: #{count}"
end
```

## Configuration

Copy `config/default.yml` to customize analysis settings:

```yaml
# Detector thresholds
detectors:
  srp:
    enabled: true
    max_methods: 7        # Flag classes with more methods
    max_instantiations: 5 # Flag high coupling
  
  law_of_demeter:
    enabled: true
    max_chain: 3          # Max method chain length

# LLM integration (future)
llm:
  enabled: false
  model: gpt-4o-mini
```

## Output

Reports are generated in the `reports/` directory:

- `pr_owner_repo_123.json` - Machine-readable analysis
- `pr_owner_repo_123.md` - Markdown report
- `pr_owner_repo_123.html` - Interactive HTML report
- `combined_report.json` - Aggregated results (batch mode)

### Sample HTML Report

The HTML report features:
- Dark theme with syntax highlighting
- Statistics dashboard
- Violations grouped by file
- Diff context highlighting
- Confidence scoring

## Architecture

```
┌─────────────────────────────────────────────┐
│              CLI / Entry Points             │
├─────────────────────────────────────────────┤
│   Services: GitHub, Diff, PR Analyzer       │
├─────────────────────────────────────────────┤
│              Facade Layer                   │
├───────┬───────┬───────┬───────┬─────────────┤
│Parser │Semant.│Detect.│Analyz.│  Reporter   │
│       │ Model │Pipeli.│  er   │             │
└───────┴───────┴───────┴───────┴─────────────┘
```

See [docs/DESIGN.md](docs/DESIGN.md) for detailed architecture documentation.

## Adding Custom Detectors

```ruby
class RubyCodeParser
  module Detectors
    class MyPrincipleDetector < BaseDetector
      def default_config
        { my_threshold: 5 }
      end

      def analyze(class_info)
        # Return array of ViolationCandidate objects
        violations = []
        
        if some_condition?(class_info)
          violations << build_candidate(
            class_info,
            score: 0.8,
            reason: "Explanation of the violation"
          )
        end
        
        violations
      end
    end
  end
end
```

Then register in `container.rb`.

## Future Roadmap

- [ ] LLM-powered analysis insights
- [ ] Diff-only analysis mode
- [ ] GitHub Actions integration
- [ ] VS Code extension
- [ ] Auto-fix suggestions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

--- 

## License

Copyright (C) 2026 Aarya Rajoju
This program is open-sourced under GNU Affero General Public License v3

[License](LICENSE)
