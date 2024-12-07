use ".."
use "collections"
use "debug"
use "files"
use "itertools"

actor Solution is AocSolution
  let _env: Env
  var _evaluators: SetIs[RuleEvaluator] = _evaluators.create()
  var _all_started: Bool = false
  var _result: U64 = 0
  var _notify: (SolutionNotify tag | None) = None
  var _part: U32 = 1
  
  new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 5

  fun ref parse_rules(iter: FileLines): RuleSet val ? =>
    let builder: RuleSet trn = RuleSet.create()
    while iter.has_next() do
        let line = iter.next()?
        line.strip()
        if line.size() == 0 then
          // rules are all ingested
          break
        else
          let splitted = line.split_by("|")
          try
            let left = splitted(0)?.u16()?
            let right = splitted(1)?.u16()?
            builder.add_rule(left, right)
          else
            // invalid rule
            continue
          end
        end
      end
    consume builder

  fun ref evaluate_rules(ruleset: RuleSet, iter: FileLines, fix: Bool = false) =>
    try
      while iter.has_next() do
        let line = iter.next()?
        let page_nums: Array[U16] iso =
          recover iso
            Iter[String](line.split_by(",").values()).filter_map[U16]({(s) => try s.u16()? end}).collect(Array[U16].create(32))
          end
        let evaluator = RuleEvaluator.create(ruleset, recover tag this end)
        _evaluators.set(evaluator)
        evaluator.evaluate(consume page_nums, fix)
      end
    end
    _all_started = true

  be part1(notify: SolutionNotify tag) =>
    _evaluators = SetIs[RuleEvaluator].create()
    _all_started = false
    _result = 0
    _notify = notify
    _part = 1
    try
      let iter = AOCUtils.get_input_lines("2024/05/input.txt", _env)?
      let ruleset = parse_rules(iter)?
      evaluate_rules(ruleset, iter, false)
    else
      notify.fail(this, 1, "Error reading input")
    end

  be part2(notify: SolutionNotify tag) =>
    _evaluators = SetIs[RuleEvaluator].create()
    _all_started = false
    _result = 0
    _notify = notify
    _part = 2
    try
      let iter = AOCUtils.get_input_lines("2024/05/input.txt", _env)?
      let ruleset = parse_rules(iter)?
      evaluate_rules(ruleset, iter, true)
    else
      notify.fail(this, 2, "Error reading input")
    end

  be result(evaluator: RuleEvaluator, page_nums: Array[U16] iso, valid: Bool) =>
    _evaluators.unset(evaluator)
    if valid then
      let middle_idx = page_nums.size().fld(2)
      try
        let middle_page_num = page_nums(middle_idx)?
        _result = _result + middle_page_num.u64()
      end
    end
    //Debug(consume page_nums)
    //Debug(if valid then "valid" else "invalid" end)
    if (_evaluators.size() == 0) and _all_started then
      try
        (_notify as SolutionNotify).done(this, _part, _result.string())
      end
    end

class val RuleSet
  let rules: SetIs[U32] = rules.create()
  
  new trn create() =>
    None

  fun ref add_rule(left: U16, right: U16) =>
    let rule = (left.u32() << left.bitwidth().u32()) or right.u32()
    rules.set(rule)

  fun box has_rule(rule: U32): Bool =>
    rules.contains(rule)


interface tag RuleEvaluationNotify
  be result(evaluator: RuleEvaluator, page_nums: Array[U16] iso, valid: Bool)


actor RuleEvaluator
  let _ruleset: RuleSet
  let _notify: RuleEvaluationNotify

  new create(ruleset: RuleSet val, notify: RuleEvaluationNotify) =>
    _ruleset = ruleset
    _notify = notify

  be evaluate(page_nums: Array[U16] iso, fix: Bool = false, fixed: Bool = false) =>
    try
      for i in Range[USize](0, page_nums.size() -1) do
        let page_num = 
          page_nums(i)?
        for j in Range[USize](i + 1, page_nums.size()) do
          let other = page_nums(j)?
          // check if we have a breaking rule of both numbers in the other
          // direction
          let rule32 = (other.u32() << other.bitwidth().u32()) or page_num.u32()
          if _ruleset.has_rule(rule32) then
            // we have a contradicting rule
            if fix then
              // fix rule
              //Debug("Swapping " + page_num.string() + " and " + other.string())
              page_nums.swap_elements(i, j)?
              // recurse until there is no more violated rule
              this.evaluate(consume page_nums where fix = true, fixed = true)
              return
            else
              _notify.result(this, consume page_nums, false)
              return
            end
          end
        end
      end
      // no contradicting rule
      _notify.result(
        this,
        consume page_nums,
        if fix then
          fixed // in fixing mode we only consider fixed page-nums as valid for counting the middle numbers
        else
          true
        end)
    else
      _notify.result(this, Array[U16], false)
    end


