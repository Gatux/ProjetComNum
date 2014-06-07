function [ teb ] = TEB( sb, b )
    error = 0;
    for i=1:4999
        if(sb(i) ~= b(i))
            error = error +1;
        end
    end
    
    teb = error / length(sb);
end

