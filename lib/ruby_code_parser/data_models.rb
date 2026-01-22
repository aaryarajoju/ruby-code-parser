# The output of Stage 3 (Detector)
ViolationCandidate = Struct.new(:file_path, :node, :smell_type, :message)

# The output of Stage 4 (Analyzer)
ValidatedViolation = Struct.new(:candidate, :is_violation, :llm_justification, :suggested_refactor)
