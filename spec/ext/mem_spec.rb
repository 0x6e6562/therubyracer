
require 'spec_helper'
require 'weakref'

describe "Memory Usage" do

  context "the low level C interface" do
    context "at the very minimum" do
      it "does not leak a context" do
        weak :context, V8::C::Context::New()
      end
    
      it "does not leak a simple object either" do
        cxt = V8::C::Context::New()
        cxt.Enter()
        begin
          weak :object, V8::C::Object::New()
        ensure
          cxt.Exit()
        end
      end
    end

    context "a ruby proxy for a JavaScript object" do
      it "holds a strong reference to the JavaScript object" do
        # pending
        handle = c::Handle::New(c::Context::New())
        handle.MakeWeak()
        handle.IsWeak().should be_true
        gc do
          handle.IsEmpty().should be_true
        end
      end
    end
  end

  before(:all) {@stress = GC.stress; GC.stress = true}
  after(:all) {GC.stress = @stress}

  before do
    @refs = {}
  end

  after do
    gc do
      for name, ref in @refs
        if ref.weakref_alive?
          fail "reference #{name} was not garbage collected"
        end
      end
    end
  end

  private
  
  def weak(name, ref)
    @refs[name] = WeakRef.new(ref)
  end

  def gc
    while !V8::C::V8::IdleNotification();end
    GC.start
    yield
  end
  
  def c
    V8::C
  end

end if GC.respond_to?(:stress=)