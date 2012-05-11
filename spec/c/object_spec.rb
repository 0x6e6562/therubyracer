require 'spec_helper'

describe V8::C::Object do
  before do
    @cxt = V8::C::Context::New()
    @cxt.Enter()
  end
  after do
    @cxt.Exit()
  end
  it "can store and retrieve a value" do
    V8::C::HandleScope() do
      o = V8::C::Object::New()
      key = V8::C::String::New("foo")
      value = V8::C::String::New("bar")
      o.Set(key, value)
      o.Get(key).Utf8Value().should eql "bar"
    end
  end
  it "can set an accessor from ruby" do
    V8::C::HandleScope() do
      o = V8::C::Object::New()
      property = V8::C::String::New("statement")
      callback_data = V8::C::String::New("I am Legend")
      left = V8::C::String::New("Yo! ")
      getter = proc do |name, info|
        V8::C::String::Concat(left, info.Data())
      end
      setter = proc do |name, value, info|
        left = value
      end
      o.SetAccessor(property, getter, setter, callback_data)
      o.Get(property).Utf8Value().should eql "Yo! I am Legend"
      o.Set(property, V8::C::String::New("Bro! "))
      o.Get(property).Utf8Value().should eql "Bro! I am Legend"
    end
  end
end