// -*- c++ -*-
/* Copyright 2002, The libsigc++ Development Team
 *  Assigned to public domain.  Use as you wish without restriction.
 */

#include <sigc++/trackable.h>
#include <sigc++/signal.h>
#include <sigc++/functors/ptr_fun.h>
#include <sigc++/functors/mem_fun.h>
#include <iostream>

int foo(int i)   {std::cout << "foo(int "<<i<<")" << std::endl; return 1;}
int bar(float i) {std::cout << "bar(float "<<i<<")" << std::endl; return 1;}

struct A : public sigc::trackable
{
  int  foo(int i)            {std::cout << "A::foo(int "<<i<<")" << std::endl; return 1;}
  void bar(std::string& str) {std::cout << "A::foo(string '"<<str<<"')" << std::endl; str="foo was here";}
};

int main()
{
  sigc::signal<int,int> sig;
  {
    A a;
    sig.connect(sigc::ptr_fun1(&foo));
    sig.connect(sigc::mem_fun1(&a, &A::foo));
    sig.connect(sigc::ptr_fun1(&bar));
    sig(1);
    std::cout << sig.size() << std::endl;
  } // a dies => auto-disconnect
  std::cout << sig.size() << std::endl;
  sig(2);

  // test reference
  A a;
  std::string str("guest book");
  sigc::signal<void,std::string&> sigstr;
  sigstr.connect(sigc::mem_fun(&a, &A::bar));
  sigstr(str);
  std::cout << str << std::endl;

  // test make_slot()
  sig.connect(sigc::ptr_fun1(&foo));
  sigc::signal<int,int> sig2;
  sig2.connect(sig.make_slot());
  sig2(3);
}
