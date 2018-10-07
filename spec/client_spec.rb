require 'rspec'
require 'wdmc/client'

describe Wdmc::Client do
  subject { Wdmc::Client.new }

  def self.hash_w_symbol_keys(*methods)
    methods.each do |method|

      describe "\##{method.join(', ')}" do
        it 'should return a Hash of some kind' do
          expect(subject.send(*method)).to be_a_kind_of(Hash)
        end

        it 'should return a Hash with keys that are symbols' do
          expect(keys_from_hash_hierarchy(subject.send(*method))).to all(be_a(Symbol))
        end
      end

    end
  end

  def self.array_of_hash_w_symbol_keys(*methods)
    methods.each do |method|

      describe "\##{method.join(', ')}" do
        it 'should return a list of hashes of some kind' do
          expect(subject.send(*method)).to be_a_kind_of(Array) .and(all(be_a_kind_of(Hash)))
        end

        it 'should return a Hash with keys that are symbols' do
          subject.send(*method).each do |entry|
            expect(keys_from_hash_hierarchy(entry)).to all(be_a(Symbol))
          end
        end
      end

    end
  end

  # each argument is a method and its arguments
  hash_w_symbol_keys(
      ['system_information'],
      ['system_state'],
      ['firmware'],
      ['device_description'],
      ['network'],
      ['storage_usage'],
      ['get_tm'],

  )

  array_of_hash_w_symbol_keys(
      ['all_shares'],
      ['all_users'],
      ['volumes'],
  )


  describe '#get_acl (has special cases)' do
    context 'with no arguments' do
      it 'should throw ArgumentError exception' do
        expect {subject.send('get_acl')}.to raise_error(ArgumentError)
      end
    end

    context 'with the name of a share that does NOT have ACLs' do
      it 'should return HTTP 404 not found' do
        expect {subject.send('get_acl', share_no_acl)}.to raise_error(RestClient::Exception, /404/)
      end
    end

    context 'with the name of a share that DOES have an ACL',
            :skip => (ENV['acl_share'] ? nil : 'reason: to enable this test, set ENV["acl_share"] to the name of a share that has ACLs') do
        hash_w_symbol_keys(['get_acl', ENV['acl_share']])
    end

  end

end
