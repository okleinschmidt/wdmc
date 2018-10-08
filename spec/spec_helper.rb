require 'rspec'
require 'wdmc'

def share_no_acl; '_'; end

def keys_from_hash_hierarchy(hierarchy)
  hierarchy.each_with_object([]) do | (k, v), keys |
    keys << k
    keys.concat(keys_from_hash_hierarchy(v)) if v.is_a? Hash
  end
end