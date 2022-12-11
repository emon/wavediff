#!/usr/bin/env ruby

require "wavefile"

wave0 = WaveFile::Reader.new(ARGV[0])
wave1 = WaveFile::Reader.new(ARGV[1])

%i(bits_per_sample channels sample_rate).each do |param|
  if wave0.format.send(param) != wave1.format.send(param)
    raise StandardError.new("wave format mismatch")
  end
end

sample_rate=wave0.format.sample_rate
format_out = wave0.format
fname_out = "out.wav"

samples_out = Array.new(sample_rate)

WaveFile::Writer.new(fname_out, format_out) do |wave_out|
  while true
    samples0 = wave0.read(sample_rate).samples
    samples1 = wave1.read(sample_rate).samples
    size = [samples0.size, samples1.size].min

    0.upto(size-1) do |n|
      samples_out[n] = [samples0[n][0] - samples1[n][0],
                        samples0[n][1] - samples1[n][1]]
    end
    pp [samples0[0], samples1[0], samples_out[0]]

    buffer = WaveFile::Buffer.new(samples_out, format_out)
    wave_out.write(buffer)
  end
end
