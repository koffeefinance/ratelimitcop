# CHANGELOG

# v1.1.0
 * [#5](https://github.com/koffeefinance/ratelimitcop/pull/5) Simplify `initialize` method to hide bucket configs in an `options` map - [@mathu97](https://github.com/mathu97).
 * [#5](https://github.com/koffeefinance/ratelimitcop/pull/5) Add `execute` method that calls `add` and blocks if rate limit is exceeded before running user's code block - [@mathu97](https://github.com/mathu97).
 * [#5](https://github.com/koffeefinance/ratelimitcop/pull/5) Add `DummyAPI` class for testing purposes, that can be used to simulate a rate limited API - [@mathu97](https://github.com/mathu97). 

# v1.0.1
 * Renaming of classes to match gem name - [@mathu97](https://github.com/mathu97).

# v1.0.0

 * Initial release of a redis backed rate limiter. Inspired by @ejfinneran's [ratelimit gem](https://github.com/ejfinneran/ratelimit) and @ncr's [alternative limiter suggestion](https://github.com/ejfinneran/ratelimit/issues/38) - [@mathu97](https://github.com/mathu97).
