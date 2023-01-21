function [new_freq,new_rfparam] = rfparam_rangecut(freq_min_Hz, freq_max_Hz, freq, rfparam)
%RFPARAM_RANGECUT Summary of this function goes here
%   Detailed explanation goes here

    pos_freq_min = find(freq==freq_min_Hz);
    pos_freq_max = find(freq==freq_max_Hz);
    
    tmp_freq = freq(1:pos_freq_max);
    tmp_rfparam = rfparam(1:pos_freq_max);
    
    new_freq = tmp_freq((pos_freq_min):end);
    new_rfparam = tmp_rfparam((pos_freq_min):end);

end

