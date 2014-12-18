# AbstInt

[![Coverage Status](https://coveralls.io/repos/yuutetu/abst_int/badge.png?branch=master)](https://coveralls.io/r/yuutetu/abst_int?branch=master)
[![Travis Status](https://travis-ci.org/yuutetu/abst_int.svg?branch=master)](https://travis-ci.org/yuutetu/abst_int)
[![Code Climate](https://codeclimate.com/github/yuutetu/abst_int.png)](https://codeclimate.com/github/yuutetu/abst_int)
[![Dependency Status](https://gemnasium.com/yuutetu/abst_int.svg)](https://gemnasium.com/yuutetu/abst_int)

AbstInt provide abstract integer. This can be used to test exhaustively.

## Installation

Add this line to your application's Gemfile:

    gem 'abst_int'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install abst_int

## Usage

```
abst2 = (AbstInt.new * 2).object # 2の倍数
abst3 = (AbstInt.new * 3).object # 3の倍数
abst2 % 2 #=> 0
abst3 % 3 #=> 0
abst2 % 3 #=> AbstInt::MultiResultError
(abst2 + 1) % 2 #=> 1

abst2_and_3 = ((AbstInt.new * 2) & (AbstInt.new * 3)).object  # 2の倍数かつ3の倍数
abst2_and_3 % 6 #=> 0
abst2_and_3 % 2 #=> 0
abst2_and_3 % 3 #=> 0

not_abst3 = (AbstInt.new * 3).not.object # 3の倍数でない
not_abst3 % 3 #=> 1 or 2 を表現するオブジェクト
not_abst3 % 3 == 0 #=> false
not_abst3 % 3 == 1 #=> AbstInt::MultiResultError
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/abst_int/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
