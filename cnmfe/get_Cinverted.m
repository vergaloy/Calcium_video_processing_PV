function C = get_Cinverted(C_raw,C_in, deconv_options)
% deconv_options = opt.options.deconv_options;
K = size(C_raw, 1);

C_raw = mat2cell(C_raw, ones(K,1), size(C_raw,2));
C_in = mat2cell(C_in, ones(K,1), size(C_in,2));
C = cell(K,1);
num_per_row = 100;
for m=1:K
    fprintf('|');
    if mod(m, num_per_row)==0
        fprintf('\n');
    end
end
fprintf('\n');


tmp_flag = false(K,1);
ind = randi(K, ceil(K/num_per_row), 1);
tmp_flag(ind) = true;
tmp_flag = num2cell(tmp_flag);
parfor k=1:size(C_raw,1)
    ck_raw = (C_raw{k}-C_in{k}).*-1;   
    tmp_sn = GetSn(ck_raw);
    ck_raw=ck_raw./tmp_sn;
    [ck, ~, tmp_options]= deconvolveCa(ck_raw, deconv_options, 'sn', 1);
    C{k} = reshape(ck, 1, []);
    C_raw{k} = ck_raw - tmp_options.b;
    
    fprintf('.');
    if tmp_flag{k}
        fprintf('\n');
    end
end
C=cell2mat(C);
end
