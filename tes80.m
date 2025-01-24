clc; clear; close all;

% Atur seed untuk generator angka acak
rng(42);

% Data training
image_folder = 'Data Latih 80';
filenames = dir(fullfile(image_folder, '*.jpg'));
total_images = numel(filenames);

% Inisialisasi variabel fitur untuk setiap gambar
fitur_solidity = zeros(1,total_images);
fitur_metric = zeros(1,total_images);
fitur_eccentricity = zeros(1,total_images);

% Memperbaiki loop untuk setiap gambar
for n = 1:total_images
    % Mendapatkan nama file gambar
    full_name = fullfile(image_folder, filenames(n).name);

    % Membaca gambar
    I = imread(full_name);
    % Konversi gambar ke ruang warna HSV
    I_hsv = rgb2hsv(I);

    % Ambil saluran warna Hue (H) dan Saturation (S)
    H = I_hsv(:,:,1);
    S = I_hsv(:,:,2);

    % Threshold untuk mengidentifikasi warna kuning
    yellow_mask = (H >= 0.1 & H <= 0.2) & (S >= 0.4 & S <= 1);

    % Threshold untuk mengidentifikasi warna hijau
    green_mask = (H >= 0.2 & H <= 0.4) & (S >= 0.4 & S <= 1);

    % Gabungkan kedua masker
    fruit_mask = yellow_mask | green_mask;

    % Operasi morfologi (Dilasi)
    se = strel('disk', 4);
    D = imdilate(fruit_mask, se);

    % Operasi morfologi (closing)
    se2 = strel('disk', 10);
    C = imclose(D, se2);

    % Deteksi objek pada gambar yang telah disegmentasi
    props = regionprops(C, 'Area', 'Perimeter', 'BoundingBox', 'Centroid', 'Eccentricity', 'Orientation');

    % Ekstraksi fitur bentuk
    stats = regionprops(C, 'Area', 'Perimeter', 'Solidity', 'Eccentricity');
    Area = stats.Area;
    Perimeter = stats.Perimeter;
    Solidity = stats.Solidity;
    Eccentricity = stats.Eccentricity;

    % Menghitung fitur bentuk berdasarkan parameter Metric dan Eccentricity
    Metric = Perimeter^2 / (4 * pi * Area);
    fitur_solidity(n) = Solidity;
    fitur_metric(n) = Metric;
    fitur_eccentricity(n) = Eccentricity;
end

% Membuat matriks fitur dengan menumpuk setiap variabel fitur
input = [fitur_solidity; fitur_metric; fitur_eccentricity];

% Membuat target untuk setiap gambar
target = zeros(1,total_images);
target(1:80) = 1; % Lemon
target(81:160) = 2; % Nipis
target(161:240) = 3; % Sunkist

% Membuat jaringan saraf tiruan dengan arsitektur yang diperbaiki
net = feedforwardnet(10, 'traingd'); % algoritma Gradient Descent
net.trainParam.epochs = 15000; % Jumlah epochs
net.trainParam.goal = 1e-6; % Nilai goal

% Melatih jaringan saraf tiruan
[net,tr] = train(net, input, target);

% Menggunakan model yang telah dilatih untuk memprediksi kelas gambar uji
output = round(sim(net,input));

save mdl802 net

[m,n] = find(output==target);
akurasi = sum(m)/total_images*100;

disp(['Akurasi pengujian: ', num2str(akurasi), '%']);
