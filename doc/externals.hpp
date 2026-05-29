#pragma once

namespace boost {

/// !EXTERNAL!
///
/// @see https://www.boost.org/doc/libs/latest/libs/mpl/index.html
namespace mpl
{
template<typename...>
struct vector;
template<typename...>
struct map;
template<typename...>
struct set;
struct true_;
struct false_;
} // namespace mpl

/// !EXTERNAL!
///
/// @see https://www.boost.org/doc/libs/latest/libs/parameter/index.html
namespace parameter
{
template<typename Tag>
struct keyword;
} // namespace parameter

/// !EXTERNAL!
///
/// @see https://www.boost.org/doc/libs/latest/libs/fusion/index.html
namespace fusion
{
struct void_;
} // namespace fusion

namespace numeric
{
namespace functional
{
/// !EXTERNAL!
template<typename, typename>
struct tag;
} // namespace functional
} // namespace numeric

namespace detail
{
/// !EXTERNAL!
template<typename>
struct pod_singleton;
/// !EXTERNAL!
template<typename>
struct function1;
/// !EXTERNAL!
template<typename>
struct function2;
} // namespace detail

namespace random
{
/// !EXTERNAL!
struct lagged_fibonacci607;
/// !EXTERNAL!
template<typename>
struct normal_distribution;
/// !EXTERNAL!
template<typename, typename>
struct variate_generator;
} // namespace random

} // namespace boost

namespace std {

/// !EXTERNAL!
///
/// @see https://en.cppreference.com/w/cpp/types/size_t
struct size_t {};

/// !EXTERNAL!
///
/// @see https://en.cppreference.com/w/cpp/container/vector
template<typename T>
struct vector {};

/// !EXTERNAL!
///
/// @see https://en.cppreference.com/w/cpp/utility/functional
template<typename>
struct binary_function {};

/// !EXTERNAL!
///
/// @see https://en.cppreference.com/w/cpp/utility/functional
template<typename>
struct unary_function {};

/// !EXTERNAL!
///
/// @see https://en.cppreference.com/w/cpp/io/basic_ostream
struct ostream {};

/// !EXTERNAL!
///
/// @see https://en.cppreference.com/w/cpp/algorithm/for_each
template<typename InputIt, typename UnaryFunction>
UnaryFunction for_each(InputIt, InputIt, UnaryFunction);

} // namespace std
