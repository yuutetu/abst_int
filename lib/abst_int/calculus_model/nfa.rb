require "set"
require "abst_int/calculus_model/dfa"

module AbstInt::CalculusModel
  class Nfa
    def initialize
      @states = Set.new
      @initial_states = Set.new
      @final_states = Set.new
      @inputs = Set.new
      @transition = {}
    end

    def add_initial state
      @states << state
      @initial_states << state
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
      @transition[state1][input] ||= Set.new
      @transition[state1][input] << state2
    end

    def exists_initial?
      not @initial_states.empty?
    end

    def to_dfa
      dfa = AbstInt::CalculusModel::Dfa.new
      dfa.set_initial @initial_states
      dfa = generate_dfa dfa, @initial_states, Set.new
      dfa.each_states do |states|
        dfa.add_final states unless (states & @final_states).empty?
      end
      return dfa
    end

    def to_s
      puts "[states]"
      @states.each {|state| puts "#{state.is_a?(Array) ? state.map(&:to_s) : state}, " }
      puts "[initial_states]"
      @initial_states.each {|state| puts "#{state.is_a?(Array) ? state.map(&:to_s) : state}, " }
      puts "[final_states]"
      @final_states.each {|state| puts "#{state.is_a?(Array) ? state.map(&:to_s) : state}, " }
      puts "[inputs]"
      @inputs.each {|input| puts "#{input}, " }
      puts "[transition]"
      @transition.each do |state1, value|
        value.each do |input, value|
          value.each do |state2|
            puts "#{state1.is_a?(Array) ? state1.map(&:to_s) : state1}, #{input}, #{state2.is_a?(Array) ? state2.map(&:to_s) : state2}"
          end if value
        end if value
      end
    end

    private
    def generate_dfa dfa, states, state_setset
      return dfa if state_setset.include? states
      old_dfa = dfa.dup
      @inputs.each do |input|
        next_states = states.inject(Set.new) do |result, state|
          @transition.try(:[], state).try(:[], input) ? result + (@transition[state][input]) : result
        end
        dfa.add_trans states, input, next_states
        dfa = generate_dfa dfa, next_states, (state_setset << states)
      end
      return dfa
    end
  end
end