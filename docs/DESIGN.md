# Design Document: Ruby Code Parser & PR Analyzer

## Executive Summary

The Ruby Code Parser is a modular static analysis pipeline designed to detect violations of software design principles (SOLID, DRY, Law of Demeter, etc.) in Ruby codebases. It provides both file-based and pull request-based analysis, making it suitable for code review automation and continuous integration workflows.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              CLI Layer                                   │
│  ┌─────────────┐  ┌─────────────────┐  ┌──────────────────────────────┐ │
│  │ analyze_pr  │  │  run_analysis   │  │      pr_processor.rb         │ │
│  └──────┬──────┘  └────────┬────────┘  └───────────────┬──────────────┘ │
└─────────┼──────────────────┼───────────────────────────┼────────────────┘
          │                  │                           │
          ▼                  ▼                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           Facade Layer                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐│
│  │                    RubyCodeParser::Facade                           ││
│  │  Orchestrates: Parser → Semantic → Detectors → Analyzer → Reporter  ││
│  └─────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          Services Layer                                  │
│  ┌───────────────────┐ ┌──────────────────┐ ┌────────────────────────┐  │
│  │   GitHubService   │ │   DiffAnalyzer   │ │ PullRequestAnalyzer    │  │
│  │  - Fetch PRs      │ │  - Parse diffs   │ │ - Orchestrate PR flow  │  │
│  │  - Download files │ │  - Extract hunks │ │ - Enrich violations    │  │
│  └───────────────────┘ └──────────────────┘ └────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           Core Pipeline                                  │
├─────────────────┬──────────────────┬──────────────────┬─────────────────┤
│  Parser Layer   │  Semantic Layer  │  Detector Layer  │ Analyzer Layer  │
├─────────────────┼──────────────────┼──────────────────┼─────────────────┤
│  ParserService  │ SemanticModel    │ DetectorPipeline │ ViolationAnalyz │
│  - syntax_tree  │   Builder        │ - SRP Detector   │   er            │
│  - ProjectAST   │ - ClassInfo      │ - OCP Detector   │ - LLM Client    │
│  - ProjectFile  │ - MethodInfo     │ - LSP Detector   │ - Prompt Strat  │
│                 │ - Enrichment     │ - DIP Detector   │   egies         │
│                 │   Visitor        │ - ... (10 total) │ - Confidence    │
│                 │                  │                  │   Scoring       │
└─────────────────┴──────────────────┴──────────────────┴─────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          Reporter Layer                                  │
│  ┌─────────────────────┐  ┌───────────────────────────────────────────┐ │
│  │   ReportService     │  │  PRReportService + PRReportFormatter      │ │
│  │  (File Analysis)    │  │  (PR Analysis with diff context)          │ │
│  └─────────────────────┘  └───────────────────────────────────────────┘ │
│                                                                          │
│  Output Formats: JSON, Markdown, HTML                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Parser Layer

**Purpose:** Convert Ruby source code into Abstract Syntax Trees (AST).

**Components:**
- `ParserService`: Wraps the `syntax_tree` gem to parse Ruby files
- `ProjectFile`: Struct holding file path, source code, and AST
- `ProjectAST`: Collection of all parsed files in a project

**Design Decisions:**
- Uses `syntax_tree` gem for modern Ruby syntax support
- Supports batch parsing of multiple files
- Graceful error handling for unparseable files

### 2. Semantic Layer

**Purpose:** Enrich ASTs with semantic metadata needed for analysis.

**Components:**
- `SemanticModelBuilder`: Orchestrates the enrichment process
- `SemanticEnrichmentVisitor`: AST visitor that extracts metadata
- `ClassInfo`: Rich representation of a class/module with:
  - Method list with signatures, visibility, metrics
  - Inheritance information
  - Module inclusions/extensions
  - Attribute accessor counts
- `MethodInfo`: Detailed method information including:
  - Call chain lengths
  - Instantiations
  - Instance variable usage
  - Structural hash for duplicate detection

**Type Inference Strategy:**
- Pluggable via `LLMTypeInferenceStrategy`
- Currently stubbed; ready for LLM integration

### 3. Detector Layer

**Purpose:** Detect potential design principle violations.

**Design Pattern:** Strategy Pattern with Template Method

**Base Class:** `Detectors::BaseDetector`
- Common `run()` method iterates over classes
- Subclasses implement `analyze(class_info)` 
- Configurable thresholds via constructor

**Implemented Detectors:**

| Detector | Principle | Detection Heuristics |
|----------|-----------|---------------------|
| `SRPDetector` | Single Responsibility | Method count, instantiation count |
| `OCPDetector` | Open/Closed | Type-checking conditionals |
| `LSPDetector` | Liskov Substitution | Method arity mismatches vs parent |
| `DIPDetector` | Dependency Inversion | Direct concrete instantiations |
| `ISPDetector` | Interface Segregation | Module method count |
| `LawOfDemeterDetector` | Law of Demeter | Method chain lengths |
| `DRYDetector` | Don't Repeat Yourself | Structural hash duplicates |
| `InformationExpertDetector` | Information Expert | External vs local state access |
| `EncapsulationDetector` | Encapsulation | Public method ratio, attr_accessor count |
| `OveruseClassMethodsDetector` | OO Design | Class vs instance method ratio |

**Adding New Detectors:**
1. Create class inheriting from `BaseDetector`
2. Implement `analyze(class_info)` returning violation candidates
3. Register in `Container`

### 4. Analyzer Layer

**Purpose:** Validate and score violation candidates.

**Components:**
- `ViolationAnalyzer`: Orchestrates LLM-based or heuristic validation
- `NullLLMClient`: Fallback when no API key is configured
- Prompt Strategies:
  - `ChainOfThoughtPromptStrategy`: Step-by-step reasoning
  - `EnsemblePromptStrategy`: Rules + counterexamples
  - `ExampleBasedPromptStrategy`: Comparison with examples

**Validation Flow:**
1. Build prompt using principle-specific strategy
2. Call LLM (or fallback heuristic)
3. Parse JSON response for confidence/justification
4. Filter by approval threshold
5. Cap confidence based on static score

### 5. Services Layer

**Purpose:** GitHub integration and PR-level analysis orchestration.

**Components:**

#### GitHubService
- Encapsulates Octokit client
- Fetches PR metadata and file changes
- Downloads raw files
- Parses patch/diff content

```ruby
github = GitHubService.new(access_token: token)
pr_info = github.fetch_pull_request(repo: "owner/repo", pr_number: 123)
pr_info.ruby_files.each { |f| ... }
```

#### DiffAnalyzer
- Parses unified diff format
- Extracts hunks with line-level changes
- Analyzes what types of changes were made
- Identifies added/removed methods and classes

```ruby
analyzer = DiffAnalyzer.new
parsed = analyzer.parse(patch_content, filename: "app/models/user.rb")
puts "Added #{parsed.total_additions} lines"
```

#### PullRequestAnalyzer
- Orchestrates the full PR analysis flow:
  1. Fetch PR info from GitHub
  2. For each Ruby file: download → analyze → collect violations
  3. Enrich violations with diff context
  4. **Filter to only violations in changed code** (by default)
  5. Generate summary with metrics

**Key Design Decision:** We analyze the **whole file** to build a proper AST and semantic model, but by default we only **report violations in/near changed lines**. This is configurable via `report_only_changed` option.

```ruby
analyzer = PullRequestAnalyzer.new(
  github_service: github,
  diff_analyzer: diff,
  facade: RubyCodeParser::Facade.new,
  config: {
    report_only_changed: true,    # Only report violations in changed code
    changed_line_tolerance: 10    # Consider lines within 10 of a change
  }
)
result = analyzer.analyze_by_url("https://github.com/owner/repo/pull/123")
```

### 6. Reporter Layer

**Purpose:** Generate human-readable and machine-parseable reports.

**File Analysis Reports:**
- `ReportService` + `ReportFormatter`
- Outputs: Markdown, HTML, JSON

**PR Analysis Reports:**
- `PRReportService` + `PRReportFormatter`
- Includes PR metadata and diff context
- Highlights violations in changed code
- Dark-themed responsive HTML

### 7. Configuration System

**Purpose:** Centralized, flexible configuration.

**Sources (in priority order):**
1. Default config (built-in)
2. Config file (YAML or JSON)
3. Environment variables
4. Runtime overrides

**Usage:**
```ruby
config = RubyCodeParser::Config.new(config_file: "config/custom.yml")
config[:detectors, :srp, :max_methods]  # => 7
config.detector_config(:srp)             # => { max_methods: 7, ... }
config.enabled_detectors                 # => [:srp, :ocp, ...]
```

### 8. Dependency Injection Container

**Purpose:** Decouple component creation from usage.

**Technology:** `dry-container` + `dry-auto_inject`

**Benefits:**
- Easy testing with mock dependencies
- Configuration-driven component wiring
- Lazy initialization

## Data Flow

### File Analysis Flow

```
┌────────────┐    ┌─────────────┐    ┌────────────────┐    ┌────────────┐
│ Ruby Files │ ─► │ ParserServ. │ ─► │ SemanticModel  │ ─► │ Detector   │
│            │    │             │    │    Builder     │    │ Pipeline   │
└────────────┘    └─────────────┘    └────────────────┘    └──────┬─────┘
                                                                   │
                        ┌──────────────────────────────────────────┘
                        ▼
┌────────────────────────────────────┐    ┌─────────────────────────────┐
│         ViolationAnalyzer          │ ─► │       ReportService         │
│  (LLM or Heuristic Validation)     │    │  (JSON, MD, HTML output)    │
└────────────────────────────────────┘    └─────────────────────────────┘
```

### PR Analysis Flow

```
┌────────────┐    ┌───────────────┐    ┌───────────────┐
│  PR URL    │ ─► │ GitHubService │ ─► │ PRInfo +      │
│            │    │  (fetch PR)   │    │ FileChanges   │
└────────────┘    └───────────────┘    └───────┬───────┘
                                               │
            ┌──────────────────────────────────┤
            ▼                                  ▼
┌───────────────────┐               ┌──────────────────┐
│   DiffAnalyzer    │               │ Download Files   │
│ (parse patches)   │               │ (via GitHub API) │
└─────────┬─────────┘               └────────┬─────────┘
          │                                  │
          │         ┌────────────────────────┘
          │         ▼
          │  ┌─────────────────┐    ┌─────────────────┐
          │  │ Facade.run_     │ ─► │ Violations +    │
          │  │  analysis()     │    │ Semantic Data   │
          │  └─────────────────┘    └────────┬────────┘
          │                                  │
          └─────────────────┬────────────────┘
                            ▼
               ┌──────────────────────────┐
               │ Enrich with Diff Context │
               │ (mark changed code)      │
               └─────────────┬────────────┘
                             ▼
               ┌──────────────────────────┐
               │    PRReportService       │
               │ (generate PR reports)    │
               └──────────────────────────┘
```

## Design Principles Applied

The codebase itself follows the design principles it detects:

### Single Responsibility
- Each detector handles one principle
- Services have focused purposes
- Formatters separate from services

### Open/Closed
- New detectors don't modify existing code
- Strategy pattern for prompt building
- Pluggable type inference

### Dependency Inversion
- Components depend on abstractions (interfaces)
- Container provides dependency injection
- LLM client is abstracted behind interface

### Interface Segregation
- Small, focused interfaces
- Struct-based data objects
- Module-level helper methods

## Future Integration: LLM Analysis

The architecture is designed for easy LLM integration:

### Current LLM Touchpoints
1. **Type Inference** (`LLMTypeInferenceStrategy`) - Currently stubbed
2. **Violation Validation** (`ViolationAnalyzer`) - Works with `NullLLMClient`
3. **Prompt Strategies** - Three strategies ready for use

### Planned LLM Integration Points

```ruby
# Future: Send entire analysis to LLM for holistic review
class LLMAnalysisService
  def analyze_results(pr_analysis_result)
    # Build comprehensive prompt with:
    # - PR context (title, description, author)
    # - All violations found
    # - Diff summary
    # - File relationships
    
    prompt = build_analysis_prompt(pr_analysis_result)
    
    # Get LLM analysis
    response = @llm_client.chat(
      model: "gpt-4o",
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: prompt }
      ]
    )
    
    # Parse structured response
    parse_llm_analysis(response)
  end
end
```

### Integration Steps
1. Enable LLM in config: `llm.enabled: true`
2. Set API key: `OPENAI_API_KEY=...`
3. (Future) Add `LLMAnalysisService` call after analysis
4. (Future) Extend reports with LLM insights

## File Structure

```
ruby-code-parser-work/
├── bin/
│   ├── run_analysis          # Analyze files
│   └── analyze_pr            # Analyze PRs
├── config/
│   └── default.yml           # Default configuration
├── lib/
│   ├── ruby_code_parser.rb   # Main entry point
│   └── ruby_code_parser/
│       ├── config.rb                      # Configuration management
│       ├── container.rb                   # DI container
│       ├── facade.rb                      # Main orchestrator
│       ├── data_models.rb                 # Core data structures
│       ├── parser.rb                      # AST parsing
│       ├── semantic_model_builder.rb      # Semantic enrichment
│       ├── detector_pipeline.rb           # Detector orchestration
│       ├── analyzer.rb                    # LLM/heuristic validation
│       ├── reporter.rb                    # File report generation
│       ├── detectors/
│       │   ├── base_detector.rb
│       │   ├── srp_detector.rb
│       │   ├── ocp_detector.rb
│       │   ├── lsp_detector.rb
│       │   ├── dip_detector.rb
│       │   ├── isp_detector.rb
│       │   ├── law_of_demeter_detector.rb
│       │   ├── dry_detector.rb
│       │   ├── information_expert_detector.rb
│       │   ├── encapsulation_detector.rb
│       │   └── overuse_class_methods_detector.rb
│       ├── services/
│       │   ├── github_service.rb          # GitHub API
│       │   ├── diff_analyzer.rb           # Diff parsing
│       │   └── pull_request_analyzer.rb   # PR orchestration
│       ├── reporters/
│       │   ├── pr_report_formatter.rb     # PR report formatting
│       │   └── pr_report_service.rb       # PR report generation
│       ├── strategies/
│       │   ├── type_inference/
│       │   │   └── llm_type_strategy.rb
│       │   └── validation/
│       │       └── prompt_strategies.rb
│       ├── support/
│       │   └── text_metrics.rb            # Text analysis utilities
│       └── visitors/
│           └── enricher_visitor.rb        # AST enrichment
├── reports/                   # Generated reports
├── spec/                      # Test suite
├── pr_processor.rb            # Batch PR processing
└── docs/
    └── DESIGN.md              # This document
```

## Usage Examples

### Analyze a Single File
```bash
bundle exec ruby ./bin/run_analysis app/models/user.rb
```

### Analyze a Pull Request
```bash
./bin/analyze_pr https://github.com/expertiza/expertiza/pull/2933
```

### Batch Process from CSV
```bash
./bin/analyze_pr --csv submissions.csv --column links --filter "E2541"
```

### Programmatic Usage
```ruby
require 'ruby_code_parser'

# Analyze files
violations = RubyCodeParser.analyze("app/models/*.rb")

# Analyze a PR
result = RubyCodeParser.analyze_pr("https://github.com/org/repo/pull/123")

# With report generation
RubyCodeParser.analyze_pr_with_report(
  "https://github.com/org/repo/pull/123",
  output_dir: "my_reports"
)
```

## Testing Strategy

- Unit tests for each detector
- Integration tests for the full pipeline
- Spec files mirror lib structure
- Factory patterns for test data

## Performance Considerations

- Lazy file parsing (on-demand)
- Configurable temp file cleanup
- Rate limit handling for GitHub API
- Candidate persistence for debugging

## Security Notes

- GitHub tokens via environment variables
- No tokens in config files
- Temp files cleaned after analysis
- Read-only GitHub API access sufficient

