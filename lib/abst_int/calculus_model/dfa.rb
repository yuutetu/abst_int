require "set"
require "abst_int/or_set"

class Object
  def try key, *args
    send key, *args
  end
end

class NilClass
  def try key, *args
    nil
  end
end

module AbstInt::CalculusModel
  class Dfa
    def initialize
      @states = Set.new
      @initial_state = nil
      @final_states = Set.new
      @inputs = Set.new
      @transition = {}
    end

    def set_initial state
      @states << state
      @initial_state = state
    end

    def add_final state
      @states << state
      @final_states << state
    end

    # [state] 1,2,3
    # [input] 'a', 'b', 'c'
    def add_trans state1, input, state2
      @states << state1 << state2
      @inputs << input
      @transition[state1] ||= {}
      @transition[state1][input] = state2
    end

    def & another_dfa
      dfa = AbstInt::CalculusModel::Dfa.new
      dfa.set_initial [self.initial_state, another_dfa.initial_state]
      dfa = generate_inter_dfa another_dfa, dfa, [self.initial_state, another_dfa.initial_state], Set.new
      dfa.each_states do |states|
        dfa.add_final states if self.final?(states[0]) && another_dfa.final?(states[1])
      end
      return dfa
    end

    def not
      cloned_self = self.perfect
      cloned_self.final_states = cloned_self.states - cloned_self.final_states
      return cloned_self
    end

    def final? state
      @final_states.include? state
    end

    def each_states &block
      @states.each &block
    end

    def to_orset
      result = nil
      @final_states.each do |final_state|
        if result.nil?
          result = generate_orset @initial_state, final_state, @states
        else
          result = result | (generate_orset @initial_state, final_state, @states)
        end
      end
      return result
    end

    def equal_transition? dfa
      @transition == dfa.transition
    end

    def self.filter_dfa
      dfa = AbstInt::CalculusModel::Dfa.new
      dfa.set_initial 'A'
      dfa.add_trans 'A', 'a', 'A'
      dfa.add_trans 'A', 'b', 'B'
      dfa.add_trans 'B', 'b', 'B'
      dfa.add_final 'A'
      dfa.add_final 'B'
      return dfa
    end

    def accept? str
      result = rec_accept? str, @initial_state
      return result
    end

    protected
    def rec_accept? str, state
      if str.length == 0
        return @final_states.include?(state)
      else
        head = str[0]
        rest = str[1..-1]
        return nil if @transition.try(:[], state).try(:[], head).nil?
        return self.rec_accept?(rest, @transition.try(:[], state).try(:[], head))
      end
    end

    def transition
      @transition
    end

    def initial_state
      @initial_state
    end

    def final_states
      @final_states
    end

    def final_states= final_states
      @final_states = final_states
    end

    def states
      @states
    end

    def perfect
      cloned_self = AbstInt::CalculusModel::Dfa.new
      cloned_self.set_initial self.initial_state
      self.final_states.each do |state|
        cloned_self.add_final state
      end
      @states.each do |state|
        @inputs.each do |input|
          if @transition.try(:[], state).try(:[], input).nil?
            cloned_self.add_trans state, input, :reject
          else
            cloned_self.add_trans state, input, @transition[state][input]
          end
        end
      end
      return cloned_self
    end

    private
    def generate_inter_dfa another_dfa, dfa, state, state_set
      return dfa if state_set.include? state
      @inputs.each do |input|
        return dfa if self.transition.try(:[], state[0]).try(:[], input).nil?
        return dfa if another_dfa.transition.try(:[], state[1]).try(:[], input).nil?
        next_state = [self.transition[state[0]][input], another_dfa.transition[state[1]][input]]
        dfa.add_trans state, input, next_state
        dfa = generate_inter_dfa another_dfa, dfa, next_state, (state_set << state)
      end
      return dfa
    end

    def generate_orset start, goal, pass_states
      return cache_check start, goal, pass_states if cache_check start, goal, pass_states
      if pass_states.empty?
        result = nil
        @transition[start].each do |input, to_state|
          if input == 'a' && to_state == goal
            result = result.nil? ? AbstInt::OrSet.new(1) : (result | AbstInt::OrSet.new(1))
          elsif input == 'b' && to_state == goal
            result = result.nil? ? AbstInt::OrSet.new(-1) : (result | AbstInt::OrSet.new(-1))
          end
        end
        result = result.nil? ? AbstInt::OrSet.new(0) : (result | AbstInt::OrSet.new(0)) if start == goal
        return result
      end
      pass_state = pass_states.to_a.first
      new_pass_states = pass_states.dup.delete pass_state
      result1 = (generate_orset start, goal, new_pass_states)
      result2 = (generate_orset start, pass_state, new_pass_states)
      result3 = (generate_orset pass_state, pass_state, new_pass_states).try(:star)
      result4 = (generate_orset pass_state, goal, new_pass_states)

      result = if result1.nil? && (result2.nil? || result4.nil?)
        nil
      elsif result1.nil?
        (if result3.nil?; result2 + result4; else result2 + result3 + result4; end)
      elsif result2.nil? || result4.nil?
        result1
      else
        result1 | (if result3.nil?; result2 + result4; else  result2 + result3 + result4; end)
      end

      save_cache start, goal, pass_states, result
      return result
    end

    def cache_check start, goal, pass_states
      return @cache.try(:[], start).try(:[], goal).try(:[], pass_states)
    end

    def save_cache start, goal, pass_states, result
      @cache ||= {}
      @cache[start] ||= {}
      @cache[start][goal] ||= {}
      @cache[start][goal][pass_states] = result
      return nil
    end
  end
end