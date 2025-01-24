clc; clear; close all;

% Data Uji
image_folder = 'Cobba';
filenames = dir(fullfile(image_folder, '*.jpg'));
total_images = numel(filenames);

load mdl802.mat

% Inisialisasi variabel fitur untuk setiap gambar
fitur_solidity = zeros(1, total_images);
fitur_metric = zeros(1, total_images);
fitur_eccentricity = zeros(1, total_images);

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
target = zeros(1, total_images);
target(1:20) = 1; % Lemon/Alpukat
target(21:40) = 2; % Nipis/Anggur
target(41:60) = 3; % Sunkist/Tomat

% Menggunakan model yang telah dilatih untuk memprediksi kelas gambar uji
output = round(sim(net, input));

% Menghitung akurasi
[m, n] = find(output == target);
akurasi = sum(m) / total_images * 100;
disp(['Akurasi pengujian: ', num2str(akurasi), '%']);

% Membuat confusion matrix
confMat = confusionmat(target, output);

% Inisialisasi variabel untuk menyimpan TP dan FP
TP = zeros(1, 3);
FP = zeros(1, 3);

% Menghitung presisi untuk setiap kelas
presisi = zeros(1, 3);
for i = 1:3
    TP(i) = confMat(i, i);
    FP(i) = sum(confMat(:, i)) - TP(i);
    presisi(i) = TP(i) / (TP(i) + FP(i));
end

disp('Presisi untuk setiap kelas:');
disp(['Kelas 1 (Lemon/Alpukat): ', num2str(presisi(1))]);
disp(['Kelas 2 (Nipis/Anggur): ', num2str(presisi(2))]);
disp(['Kelas 3 (Sunkist/Tomat): ', num2str(presisi(3))]);

disp('True Positives (TP) untuk setiap kelas:');
disp(['TP Kelas 1 (Lemon/Alpukat): ', num2str(TP(1))]);
disp(['TP Kelas 2 (Nipis/Anggur): ', num2str(TP(2))]);
disp(['TP Kelas 3 (Sunkist/Tomat): ', num2str(TP(3))]);

disp('False Positives (FP) untuk setiap kelas:');
disp(['FP Kelas 1 (Lemon/Alpukat): ', num2str(FP(1))]);
disp(['FP Kelas 2 (Nipis/Anggur): ', num2str(FP(2))]);
disp(['FP Kelas 3 (Sunkist/Tomat): ', num2str(FP(3))]);

% Menyimpan variabel TP dan FP ke workspace
assignin('base', 'TP', TP);
assignin('base', 'FP', FP);
