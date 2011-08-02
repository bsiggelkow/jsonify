######################################################################
# Jsonify::BlankSlate is based on Jim Weirich's BlankSlate.
#
# Copyright 2004, 2006 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.
#
# BlankSlate provides an abstract base class with no predefined
# methods (except for <tt>\_\_send__</tt> and <tt>\_\_id__</tt>).
# BlankSlate is useful as a base class when writing classes that
# depend upon <tt>method_missing</tt> (e.g. dynamic proxies).
#
# This Jsonify implementation of BlankSlate is identical; with the
# exception that it does not include the Kernel, Module, and Object
# patches.
#
module Jsonify
  class BlankSlate
    class << self

      # Hide the method named +name+ in the BlankSlate class.  Don't
      # hide +instance_eval+ or any method beginning with "__".
      def hide(name)
        if instance_methods.include?(name.to_s) and
          name !~ /^(__|instance_eval)/
          @hidden_methods ||= {}
          @hidden_methods[name.to_sym] = instance_method(name)
          undef_method name
        end
      end

      def find_hidden_method(name)
        @hidden_methods ||= {}
        @hidden_methods[name] || superclass.find_hidden_method(name)
      end

      # Redefine a previously hidden method so that it may be called on a blank
      # slate object.
      def reveal(name)
        hidden_method = find_hidden_method(name)
        fail "Don't know how to reveal method '#{name}'" unless hidden_method
        define_method(name, hidden_method)
      end
    end

    instance_methods.each { |m| hide(m) }
  end
end