dnl Copyright 2002, The libsigc++ Development Team 
dnl 
dnl This library is free software; you can redistribute it and/or 
dnl modify it under the terms of the GNU Lesser General Public 
dnl License as published by the Free Software Foundation; either 
dnl version 2.1 of the License, or (at your option) any later version. 
dnl 
dnl This library is distributed in the hope that it will be useful, 
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of 
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
dnl Lesser General Public License for more details. 
dnl 
dnl You should have received a copy of the GNU Lesser General Public 
dnl License along with this library; if not, write to the Free Software 
dnl Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
dnl
divert(-1)
include(template.macros.m4)

dnl
dnl  How to call the darn thing!
define([LAMBDA_GROUP_FACTORY],[dnl
template <class T_functor, LOOP(class T_type%1, $1)>
lambda<lambda_group$1<T_functor, LOOP(T_type%1, $1)> >
group(const T_functor& _A_func, LOOP(T_type%1 _A_%1, $1))
{
  typedef lambda_group$1<T_functor, LOOP(T_type%1, $1)> T_lambda;
  return lambda<T_lambda>(T_lambda(_A_func, LOOP(_A_%1, $1)));
}

])
dnl
dnl  How to call the darn thing!
define([LAMBDA_GROUP_DO],[dnl
define([_L_],[LOOP(_A_%1, $2)])dnl
define([_T_],[LOOP(T_arg%1, $2)])dnl
dnl Please someone get a gun!
  template <LOOP(class T_arg%1, $2)>
  typename deduce_result_type<LOOP(T_arg%1,$2)>::type
  operator() (LOOP(T_arg%1 _A_%1, $2)) const
    { return (func_(LOOP(_A_%1, $2)))(LOOP(value%1_(_L_),$1)); }

])
dnl
dnl This really doesn't have much to do with lambda other than
dnl holding lambdas with in itself.
define([LAMBDA_GROUP],[dnl
template <class T_functor, LOOP(class T_type%1, $1)>
struct lambda_group$1 : public lambda_base
{
  typedef typename functor_trait<T_functor>::result_type result_type;dnl
FOR(1, $1,[
  typedef typename lambda<T_type%1>::lambda_type   value%1_type;])
  typedef typename lambda<T_functor>::lambda_type functor_type;

  template <LOOP(class T_arg%1=void,$2)>
  struct deduce_result_type
    { typedef typename sigc::deduce_result_type<
                typename functor_type::deduce_result_type<LOOP(T_arg%1,$2)>::type,dnl
LOOP([
                typename value%1_type::deduce_result_type<LOOP(T_arg%1,$2)>::type], $1)
        >::type type; };

  result_type
  operator ()() const;

FOR(1,CALL_SIZE,[[LAMBDA_GROUP_DO($1,%1)]])dnl
  lambda_group$1(const T_functor& _A_func, LOOP(const T_type%1& _A_%1, $1))
    : LOOP(value%1_(_A_%1), $1), func_(_A_func) {}dnl

FOR(1, $1,[
  value%1_type value%1_;])
  mutable functor_type func_;
};

template <class T_functor, LOOP(class T_type%1, $1)>
typename lambda_group$1<T_functor, LOOP(T_type%1, $1)>::result_type
lambda_group$1<T_functor, LOOP(T_type%1, $1)>::operator ()() const
  { return (func_())(LOOP(value%1_(), $1)); }


template <class T_action, class T_functor, LOOP(class T_type%1, $1)>
void visit_each(const T_action& _A_action,
                const lambda_group$1<T_functor, LOOP(T_type%1, $1)>& _A_target)
{dnl
FOR(1, $1,[
  visit_each(_A_action, _A_target.value%1_);])
  visit_each(_A_action, _A_target.func_);
}


])
divert(0)dnl
__FIREWALL__
#include <sigc++/adaptors/lambda/base.h>

namespace sigc {

FOR(1,3,[[LAMBDA_GROUP(%1, CALL_SIZE)]])
FOR(1,3,[[LAMBDA_GROUP_FACTORY(%1)]])

} /* namespace sigc */
