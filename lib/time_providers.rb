class NormalTimeProvider
  def now
    Time.now
  end

  def my_sleep(seconds)
    puts "Sleeping for #{seconds} seconds"
    Celluloid.sleep(seconds)
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

  def my_sleep(seconds)
    advance(seconds)
  end
end
