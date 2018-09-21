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

    context 'with a share that does NOT have ACLs as the first argument' do
      it 'should return HTTP 404 not found' do
        expect {subject.send('get_acl', share_no_acl)}.to raise_error(RestClient::Exception, /404/)
      end
    end

    context 'with a share that does have an ACL as the first argument' do
      # it 'should behave like other methods that return a hash with symbols as keys' do
        hash_w_symbol_keys(['get_acl', share_w_acl])
      # end
    end

  end

end
