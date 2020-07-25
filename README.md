# Petunjuk Penggunaan Program
- Pada folder yang mengandung `Makefile`, Ketik `make` pada terminal.
- Program akan dikompilasi dengan perintah `Makefile`.
- Setelah itu, jalankan program dengan perintah `./prog <JUMLAH_THREAD> <N>`.
- Contoh: `./prog 10 200` akan menjalankan program dengan jumlah thread = 10 dan jumlah N = 200.
- Akan keluar file output dengan nama `output-<N>` pada direktori yang terdapat Makefile.
- Untuk menghapus program executable yang sudah dikompilasi, gunakan perintah `make clean`.

# Pembagian Tugas
- Fata Nugraha (13517109) mengerjakan fungsi dijkstra serial (mengubah matriks menjadi 1D), fungsi untuk memparalelkan dijkstra.
- Edward Alexander jaya (13517115) mengerjakan fungsi menulis output file dan pengujian pada server.

# Laporan Pengerjaan
#### Deskripsi Solusi Paralel
- Setiap thread mengerjakan dijkstra untuk setiap node pada matriks. Jika suatu thread sudah mengerjakan dijkstra suatu node, namun terdapat node lain yang belum dijikstrakan, maka thread akan mengambil node lain tersebut. Jika semua node sudah di-dijkstrakan, proses dijkstra selesai.
Contoh:
Pada matriks dengan jumlah node (N) = 100 dan jumlah thread = 5, dengan counter node[0.. N-1]
  - Thread dengan rank = 0 menjalankan algoritma dijkstra dengan counter = 0, counter++ (node asal = 0)
  - Thread dengan rank = 1 menjalankan algoritma dijkstra dengan counter = 1, counter++ (node asal = 1)
  - Thread dengan rank = 2 menjalankan algoritma dijkstra dengan counter = 2, counter++ (node asal = 2)
  - Thread dengan rank = 3 menjalankan algoritma dijkstra dengan node asal 3, counter++ (node asal = 3)
  - Thread dengan rank = 4 menjalankan algoritma dijkstra dengan node asal 4, counter++ (node asal = 4)
  - Sekarang counter = 5. Misalkan thread dengan rank = 0 mengerjakan dijkstranya lebih cepat daripada thread lain, maka thread dengan rank = 0 yang menjalankan dijkstra pada node asal = 5, counter++
  - Sekarang counter = 6. Misalkan thread dengan rank = 2 mengerjakan dijkstranya lebih cepat daripada thread lain, maka thread dengan rank = 2 yang menjalankan dijkstra pada node asal = 6, counter++
  - Sekarang counter = 7. Misalkan thread dengan rank = 2 mengerjakan dijkstranya lebih cepat daripada thread lain, maka thread dengan rank = 4 yang menjalankan dijkstra pada node asal = 7, counter++
  - Proses ini akan terus diulangi sampai counter = N-1

#### Analisis Solusi Paralel
Program paralel diawali dengan beberapa baris kode:

    #pragma omp parallel for num_threads (thread_count)
    for (idx = 0; idx < N; ++idx)
    {
        dijkstra(graph, idx);
    }

Iterasi setiap node asal pada matriks. Thread yang sudah dijadwalkan oleh CPU (sesuai dengan penjelasan pada deskripsi solusi paralel) akan menjalankan dijkstra.
Iterasi berhenti sampai semua node asal pada matriks sudah di-dijkstrakan.

Tidak ada solusi yang lebih cepat. Jika digunakan #pragma omp task, overhead untuk membuat task cukup besar sehingga lebih lama daripada solusi kami. (Sudah dites).

#### Jumlah Thread yang Digunakan
- Terdapat dua thread yang digunakan. Alasannya, dengan command `lscpu`, ditemukan  `Thread(s) per core:  1`, `Core(s) per socket:  1`, `Socket(s): 2`, berarti terdapat 2 CPU x 1 thread = 2 thread yang digunakan.
- Tidak ada perbedaan signifikan pada performance saat thread lebih dari dua dibandingkan dengan thread sama dengan dua.

#### Pengukuran Kinerja untuk tiap Kasus Uji
Berikut adalah hasil pengujian yang dikerjakan pada server 13517115@167.205.35.153, 13517115@167.205.35.154, 13517115@167.205.35.155:
- **N = 100**

  | Tipe | Percobaan 1 | Percobaan 2 | Percobaan 3 |
  |---|--- |---|---|
  | Serial   | 10842.209012 µs  | 11333.854985 µs    | 11208.159995 µs|
  | Paralel | 5777.048995 µs | 5847.997003 µs | 5822.092993 µs|

- **N = 500**

  | Tipe  |  Percobaan 1 | Percobaan 2  | Percobaan 3  |
  |---|---|---|---|
  | Serial |  1230475.542019 µs |  1236974.533007 µs |  1237225.032004 µs |
  | Paralel  |  635462.980979 µs | 627214.675973 µs  |  627379.151992 µs |
- **N = 1000**

  | Tipe  |  Percobaan 1 | Percobaan 2  | Percobaan 3  |
  |---|---|---|---|
  | Serial | 10998820.698995 µs | 11153728.835983 µs | 11047818.458988 µs  |
  | Paralel  | 5623697.264993 µs  |  5584505.690989 µs | 5551363.512990 µs|
- **N = 3000**

  | Tipe  |  Percobaan 1 | Percobaan 2  | Percobaan 3  |
  |---|---|---|---|
  | Serial | 338924513.287988 µs  |  337759398.666996 µs |  460236280.571000 µs |
  | Paralel  | 167446967.266005 µs | 170605410.009011 µs |  166687187.794014 µs|

#### Analisis Perbandingan Kinerja Serial dan Paralel
- Pada program serial, thread yang dijalankan hanya satu. Pada program paralel, terdapat dua thread yang dijalankan. Seharusnya kecepatan program paralel dua kali lebih cepat daripada program serial.
- Sesuai dengan hasil percobaan, kecepatan program paralel kurang lebih dua kali lebih cepat daripada program serial.



