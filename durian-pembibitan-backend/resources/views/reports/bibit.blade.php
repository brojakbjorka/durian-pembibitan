<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Laporan Daftar Bibit Durian</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #333;
            margin: 0;
            padding: 0;
            font-size: 12px;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #2e7d32;
            padding-bottom: 10px;
        }
        .header h1 {
            color: #2e7d32;
            margin: 0 0 5px 0;
            font-size: 20px;
        }
        .header p {
            margin: 0;
            color: #666;
            font-size: 12px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            padding: 8px 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #2e7d32;
            color: white;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .status-sehat {
            color: #2e7d32;
            font-weight: bold;
        }
        .status-sakit {
            color: #c62828;
            font-weight: bold;
        }
        .status-mati {
            color: #616161;
            font-weight: bold;
        }
        .footer {
            margin-top: 30px;
            text-align: right;
            font-size: 10px;
            color: #777;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Laporan Daftar Bibit Durian</h1>
        <p>Sistem Informasi Pembibitan Durian (Audit Trail Enabled)</p>
        <p>Tanggal Cetak: {{ now()->format('d-m-Y H:i:s') }}</p>
    </div>

    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Kode Bibit</th>
                <th>Varietas</th>
                <th>Tanggal Tanam</th>
                <th>Status</th>
                <th>Lokasi Blok</th>
                <th>Koordinat</th>
            </tr>
        </thead>
        <tbody>
            @foreach($bibits as $index => $bibit)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td><strong>{{ $bibit->kode_bibit }}</strong></td>
                <td>{{ $bibit->varietas }}</td>
                <td>{{ $bibit->tanggal_tanam?->format('d-m-Y') }}</td>
                <td>
                    <span class="status-{{ strtolower($bibit->status) }}">
                        {{ $bibit->status }}
                    </span>
                </td>
                <td>{{ $bibit->lokasi_blok }}</td>
                <td>
                    @if($bibit->latitude && $bibit->longitude)
                        {{ $bibit->latitude }}, {{ $bibit->longitude }}
                    @else
                        -
                    @endif
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="footer">
        <p>Dicetak otomatis oleh Sistem Informasi Pembibitan Durian.</p>
    </div>
</body>
</html>
