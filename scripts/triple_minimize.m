clear my_vals; 
vals = 0.2:0.2:2; 
my_vals = zeros(length(vals),length(vals),length(vals)); 
for i = 1:length(vals)
for j = 1:length(vals)
for k = 1:length(vals)
my_vals(i,j,k) = QM_function(B,Hm,mask,vals(i),vals(j),vals(k));
end
end
end
[x,y,z] = ind2sub(size(my_vals),find(my_vals==min(my_vals(:))));

vals1 = vals(x)-0.2:0.05:vals(x)+0.2;
vals2 = vals(y)-0.2:0.05:vals(y)+0.2;
vals3 = vals(z)-0.2:0.05:vals(z)+0.2;
my_vals = zeros(length(vals1),length(vals1),length(vals1)); 
for i = 1:length(vals1)
for j = 1:length(vals1)
for k = 1:length(vals1)
my_vals(i,j,k) = QM_function(B,Hm,mask,vals1(i),vals2(j),vals3(k));
end
end
end
[x,y,z] = ind2sub(size(my_vals),find(my_vals==min(my_vals(:))));

vals1 = vals1(x)-0.05:0.01:vals1(x)+0.05;
vals2 = vals2(y)-0.05:0.01:vals2(y)+0.05;
vals3 = vals3(z)-0.05:0.01:vals3(z)+0.05;
my_vals = zeros(length(vals1),length(vals1),length(vals1)); 
for i = 1:length(vals1)
for j = 1:length(vals1)
for k = 1:length(vals1)
my_vals(i,j,k) = QM_function(B,Hm,mask,vals1(i),vals2(j),vals3(k));
end
end
end
[x,y,z] = ind2sub(size(my_vals),find(my_vals==min(my_vals(:))));
vals=[vals1(x),vals2(y),vals3(z)];

sigma = vals(1); noise_coef=vals(2); noise_sigma=vals(3);



