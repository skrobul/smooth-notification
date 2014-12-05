class NormalTimeProvider
  def now
    Time.now
  end

  def sleep(seconds)
    sleep seconds
  end

  def advance
    raise NotImplemented
  end
end

class FakeTimeProvider
  attr_accessor :now

  def initialize
    @now = Time.now
  end

  def advance(seconds)
    @now += seconds
  end

  def sleep(seconds)
    advance(seconds)
  end
end
