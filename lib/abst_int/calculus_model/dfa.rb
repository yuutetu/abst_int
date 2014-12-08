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

  def [] some
    return some
  end

  def + some
    return some
  end

  def | some
    return some
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
      return generate_orset
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

    def generate_orset

      # アルファベットを数字に変更
      current_dfa = AbstInt::CalculusModel::Dfa.new
      current_dfa.set_initial @initial_state
      @final_states.each do |state|
        current_dfa.add_final state
      end
      @transition.each do |state1, value|
        value.each do |input, state2|
          case input
          when 'a'
            current_dfa.add_trans state1, AbstInt::OrSet.new(1), state2
          when 'b'
            current_dfa.add_trans state1, AbstInt::OrSet.new(-1), state2
          end
        end
      end

      remove_states = @states - ([@initial_state] + @final_states.to_a)

      remove_states.each do |state|
        current_dfa = self_remain_state_for_ofset_dfa! state, current_dfa
      end

      removed_dfa_without_final = current_dfa
      current_dfa = nil
      current_orset = nil

      @final_states.each do |final|
        current_dfa = removed_dfa_without_final
        remove_states = current_dfa.states - [@initial_state, final]
        remove_states.each do |state|
          current_dfa = self_remain_state_for_ofset_dfa! state, current_dfa
        end
        if @initial_state == final then
          current_dfa.transition[@initial_state].each do |input, state2|
            if state2 == final
              current_orset = current_orset | input.star
            end
          end
        else
          trans_cache = {}
          current_dfa.transition.each do |state1, value|
            value.each do |input, state2|
              trans_cache[state1] ||= {}
              trans_cache[state1][state2] = input
            end
          end
          match_orset = (trans_cache[@initial_state][@initial_state] | (trans_cache[@initial_state][final] + trans_cache[final][final].try(:star) + trans_cache[final][@initial_state])).try(:star) + trans_cache[@initial_state][final] + trans_cache[final][final].try(:star)
          current_orset = current_orset | match_orset
        end
      end

      return current_orset
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

    protected
    def self_remain_state_for_ofset_dfa! state, current_dfa
      new_dfa = AbstInt::CalculusModel::Dfa.new
      in_states, out_states = Set.new, Set.new
      current_dfa.transition.each do |state1, value|
        value.each do |input, state2|
          (out_states << state2; next) if state1 == state && state2 != state
          (in_states  << state1; next) if state1 != state && state2 == state
          new_dfa.add_trans state1, input, state2
        end
      end

      trans_cache = {}
      current_dfa.transition.each do |state1, value|
        value.each do |input, state2|
          if in_states.include?(state1) ||
             out_states.include?(state2) ||
             state == state1 ||
             state == state2 then
            trans_cache[state1] ||= {}
            trans_cache[state1][state2] = input
          end
        end
      end

      in_states.each do |in_state|
        out_states.each do |out_state|
          right_orset = nil
          if trans_cache.try(:[], in_state).try(:[], state) && trans_cache.try(:[], state).try(:[], out_state) then
            if trans_cache.try(:[], state).try(:[], state) then
              right_orset = trans_cache[in_state][state] + trans_cache[state][out_state].star + trans_cache[state][out_state]
            else
              right_orset = trans_cache[in_state][state] + trans_cache[state][out_state]
            end
          end
          if trans_cache.try(:[], in_state).try(:[], out_state) && right_orset then
            new_orset = trans_cache[in_state][out_state] | right_orset
          elsif right_orset then
            new_orset = right_orset
          else
            new_orset = trans_cache[in_state][out_state]
          end

          new_dfa.add_trans in_state, new_orset, out_state if new_orset
        end
      end

      return new_dfa
    end
  end
end