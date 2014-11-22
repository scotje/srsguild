def rand_str(length)
  result = String.new
  while (result.length < length)
    if ((length - result.length) > 40)
      result += Digest::SHA1.hexdigest(Time.now.to_s + rand(100000000).to_s)
    else
      return result + Digest::SHA1.hexdigest(Time.now.to_s + rand(100000000).to_s)[0..(length-result.length-1)]
    end
  end
end
