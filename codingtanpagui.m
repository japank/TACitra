nama_folder = 'dataset';
% membaca nama file yang berformat jpg
nama_file = dir(fullfile(nama_folder,'*.jpg'));
% menghitung jumlah file yang dibaca
jumlah_file = numel(nama_file);
% menginisialisasi variabel ciri
% melakukan ekstraksi ciri terhadap seluruh file yang dibaca
for n = 1:jumlah_file
    % membaca file citra
    Img = imread(fullfile(nama_folder,nama_file(n).name));
   %rezise
    Img = imresize(Img,[500,500]);
    %merubah ruang warna
    bw = im2bw(Img,0.5);
    %melakukan operasi crop
    bw = imcrop(bw, [50, 50, 300, 300]);
    % melakukan median filtering
    bw = medfilt2(~bw,[5,5]);
    %Penajaman gambar pada gambar dengan Highpass Filter
    hpf1=[-1 -1 -1;-1 8 -1;-1 -1 -1]; 
    bw=uint8(conv2(double(bw),hpf1,'same'));
    %segmentasi
    m = zeros(size(bw,1),size(bw,2)); 
    m(59:200,100:200) = 1; 
    bw = activecontour(bw,m,350); 
     % melakukan operasi morfologi filling holes
    bw = imfill(bw,'holes');
    % melakukan operasi morfologi area opening
    bw = bwareaopen(bw,750);
     %segmentasi garis
   % bw= edge(bw,'roberts'); 
   
    str = strel('disk',5);
    bw = imdilate(bw,str);
   
    % melakukan ekstraksi ciri terhadap citra biner hasil thresholding
    stats1  = regionprops(bw, 'all');
    area = stats1.Area;
    perimeter = stats1.Perimeter;
    eccentricity1 = stats1.Eccentricity;
    metric1 = 4*pi*area/perimeter^2;
    ece(n) = mean(eccentricity1);
    met(n) = mean(metric1);
    X = [ece;met]';
end
 
opts = statset('Display','final');
%k-means clustering berdasarkan bentuk dan ukuran, dengan cluster berjumlah 2
[idx,C] = kmeans(X,2);
%clustering
 
%tampilkan hasil clustering
figure;
plot(X(idx==2,1),X(idx==2,2),'r.','MarkerSize',24)%cluster 1
hold on
plot(X(idx==1,1),X(idx==1,2),'g.','MarkerSize',24)%cluster 2
legend('Cluster 1','Cluster 2','Location','best')%window detail
title('Cluster ')%judul
xlabel('ukuran')%kordinat x
ylabel('bentuk')%kordinat y
h = gca;
xlim(h.XLim+.5*[-1,1])%batas sumbu x
ylim(h.YLim+.5*[-1,1])%batas sumbu y
hold off
 
%klasifikasi tidak terbimbing
 
Y = cell(numel(idx),1);%menghitung elemen di matrix idx
for n = 1:numel(Y)
 if idx(n,:) == 1
 Y{n,:} = 'motor';
 elseif idx(n,:) == 2
 Y{n,:} = 'mobil';
 end
 strcat(num2str(n),'.jpg :',Y{n,:})
 
end