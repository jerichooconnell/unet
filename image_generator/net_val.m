function ys = net_val(x)

load('net.mat')

xnew = reshape(x,numel(x)./4,4);

ys = net(xnew');

end