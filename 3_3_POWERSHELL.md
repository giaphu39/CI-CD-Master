# Hướng Dẫn Tự Học PowerShell Cho DevOps

Tài liệu này cung cấp cái nhìn tổng quan về PowerShell, lý do tại sao nên sử dụng nó thay thế cho Bash trên Windows, và tổng hợp các câu lệnh từ cơ bản đến nâng cao để giúp bạn đọc hiểu cũng như tự viết các script tự động hóa.

---

## 📌 Mục Lục (Table of Contents)

- [1. PowerShell Là Gì?](#1-powershell-là-gì)
- [2. Tại Sao Nên Dùng PowerShell Thay Thế Bash Trên Windows?](#2-tại-sao-nên-dùng-powershell-thay-thế-bash-trên-windows)
- [3. Các Lệnh Cơ Bản Cần Biết (Basic Cmdlets)](#3-các-lệnh-cơ-bản-cần-biết-basic-cmdlets)
  - [Lệnh Điều Hướng & Quản Lý Hệ Thống](#lệnh-điều-hướng-quản-lý-hệ-thống)
  - [Lệnh Tra Cứu & Trợ Giúp](#lệnh-tra-cứu-trợ-giúp)
  - [Quản Lý Bảo Mật & Chạy Script](#quản-lý-bảo-mật-chạy-script)
- [4. Ngôn Ngữ Scripting: Từ Cơ Bản Đến Nâng Cao](#4-ngôn-ngữ-scripting-từ-cơ-bản-đến-nâng-cao)
  - [4.1. Khai Báo Biến (Variables)](#41-khai-báo-biến-variables)
  - [4.2. Các Toán Tử So Sánh (Comparison Operators)](#42-các-toán-tử-so-sánh-comparison-operators)
  - [4.3. Pipeline & Lọc Dữ Liệu](#43-pipeline-lọc-dữ-liệu)
  - [4.4. Vòng Lặp (Loops)](#44-vòng-lặp-loops)
  - [4.5. Xử Lý Lỗi (Error Handling)](#45-xử-lý-lỗi-error-handling)
  - [4.6. Xuất Dữ Liệu Đồng Bộ (Out-Host)](#46-xuất-dữ-liệu-đồng-bộ-out-host)

---

## 1. PowerShell Là Gì?

**PowerShell** là một giải pháp tự động hóa tác vụ và quản lý cấu hình được phát triển bởi Microsoft. Nó bao gồm một shell dòng lệnh (command-line shell), một ngôn ngữ kịch bản (scripting language) và một framework quản lý cấu hình.

Không giống như hầu hết các shell khác (như Bash, Zsh) chấp nhận và trả về văn bản (text/string), PowerShell được xây dựng trên nền tảng **.NET Common Language Runtime (CLR)** và chấp nhận/trả về các **đối tượng (Objects)** của .NET. Sự khác biệt cơ bản này thay đổi hoàn toàn cách chúng ta quản lý và tự động hóa hệ thống.

---

## 2. Tại Sao Nên Dùng PowerShell Thay Thế Bash Trên Windows?

Khi làm việc trên hệ điều hành Windows, PowerShell là sự lựa chọn tối ưu hơn Bash vì những lý do sau:

1. **Native & Tích hợp sẵn:** PowerShell có sẵn trên mọi máy Windows mà không cần cài đặt thêm môi trường giả lập (như Git Bash, Cygwin) hoặc chạy máy ảo WSL2.
2. **Hướng đối tượng (Object-oriented) vs Hướng văn bản:**
   * Trong **Bash**, đầu ra của lệnh là văn bản thô. Để lấy một thông tin cụ thể (ví dụ: lấy cột IP), bạn phải dùng các công cụ lọc chuỗi phức tạp như `grep`, `awk`, `sed`, `cut`.
   * Trong **PowerShell**, đầu ra là các đối tượng có cấu trúc. Bạn có thể truy xuất trực tiếp các thuộc tính bằng cách gọi tên của nó. Ví dụ: `(Get-Process -Name chrome).Id` sẽ lấy trực tiếp PID của Chrome mà không cần phân tích văn bản.
3. **Không bị lỗi socket và đường dẫn hệ thống (Path):**
   * Các công cụ chạy ở Windows host như Docker Desktop sử dụng Windows Named Pipes (`npipe://`). Khi bạn dùng Bash (đặc biệt là WSL Bash), nó sẽ cố tìm `/var/run/docker.sock` và dẫn đến lỗi kết nối Docker daemon.
   * PowerShell chạy trực tiếp trên Windows nên giao tiếp mượt mà với các Service của Windows host mà không bị lỗi cấu trúc đường dẫn unix.
4. **PowerShell Core (Đa nền tảng):** Phiên bản PowerShell Core hiện đại (`pwsh`) hỗ trợ cả Windows, macOS và Linux, giúp bạn viết script chạy được trên mọi hệ điều hành.

---

## 3. Các Lệnh Cơ Bản Cần Biết (Basic Cmdlets)

Các câu lệnh trong PowerShell được đặt tên theo quy tắc **Động từ - Danh từ (Verb-Noun)** rất dễ nhớ (ví dụ: `Get-Process`, `Stop-Service`).

### Lệnh Điều Hướng & Quản Lý Hệ Thống
| Lệnh PowerShell | Lệnh Bash tương đương | Ý nghĩa |
| :--- | :--- | :--- |
| `Get-Location` (alias: `pwd`) | `pwd` | Xem thư mục hiện tại |
| `Set-Location` (alias: `cd`) | `cd` | Di chuyển thư mục |
| `Get-ChildItem` (alias: `ls` hoặc `dir`) | `ls` | Liệt kê các file/thư mục |
| `Copy-Item` (alias: `cp`) | `cp` | Sao chép file/thư mục |
| `Remove-Item` (alias: `rm`) | `rm` | Xóa file/thư mục |
| `New-Item` (alias: `mkdir`, `touch`) | `mkdir` / `touch` | Tạo file hoặc thư mục mới |

### Lệnh Tra Cứu & Trợ Giúp
* **`Get-Command`:** Tìm kiếm các lệnh có sẵn trong hệ thống.
  ```powershell
  # Tìm tất cả các lệnh liên quan đến dịch vụ (Service)
  Get-Command *Service*
  ```
* **`Get-Help`:** Xem tài liệu hướng dẫn và ví dụ chạy lệnh (tương đương `man` trong Linux).
  ```powershell
  # Xem hướng dẫn chi tiết lệnh Get-Process
  Get-Help Get-Process -Detailed
  ```
* **`Get-Member`:** Xem các thuộc tính (properties) và phương thức (methods) của một đối tượng.
  ```powershell
  # Xem các thuộc tính của đối tượng Process để lọc thông tin
  Get-Process | Get-Member
  ```

### Quản Lý Bảo Mật & Chạy Script
Mặc định Windows khóa không cho chạy file script `.ps1` để bảo vệ hệ thống. Bạn cần cấp quyền chạy bằng lệnh:
```powershell
# Cho phép chạy script local không cần ký số, chỉ áp dụng cho session hiện tại
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

---

## 4. Ngôn Ngữ Scripting: Từ Cơ Bản Đến Nâng Cao

### 4.1. Khai Báo Biến (Variables)
Tất cả các biến trong PowerShell đều bắt đầu bằng ký tự `$`.
```powershell
$Username = "amalkin39"
$Project = "3_1_kubernetes-demo-api"
# Nối chuỗi (String Interpolation) bằng dấu ngoặc kép
$ImageName = "${Username}/${Project}:latest" 
```

### 4.2. Các Toán Tử So Sánh (Comparison Operators)
PowerShell không dùng các ký hiệu như `==`, `!=`, `<`, `>` để so sánh mà dùng các toán tử ký tự:
* `-eq` (Equal): Bằng
* `-ne` (Not Equal): Không bằng
* `-gt` (Greater Than): Lớn hơn
* `-lt` (Less Than): Nhỏ hơn
* `-like` (Wildcard comparison): So sánh chứa ký tự đại diện (ví dụ: `*demo*`)
* `-contains` (Collection comparison): Kiểm tra xem danh sách có chứa phần tử hay không

```powershell
$Age = 20
if ($Age -ge 18) {
    Write-Host "Đã đủ tuổi trưởng thành" -ForegroundColor Green
}
```

### 4.3. Pipeline & Lọc Dữ Liệu
Nhờ cơ chế Object, việc dùng pipeline trong PowerShell cực kỳ mạnh mẽ:
* **`Where-Object` (alias: `?`):** Lọc các phần tử thỏa mãn điều kiện.
  ```powershell
  # Tìm các tiến trình đang sử dụng CPU lớn hơn 10%
  Get-Process | Where-Object {$_.CPU -gt 10}
  ```
* **`Select-Object` (alias: `select`):** Chọn các thuộc tính cần hiển thị.
  ```powershell
  # Chỉ lấy tên và ID của các tiến trình chrome
  Get-Process -Name chrome | Select-Object -Property ProcessName, Id
  ```

### 4.4. Vòng Lặp (Loops)
```powershell
# Cách 1: Vòng lặp foreach truyền thống
$Names = @("Pod1", "Pod2", "Pod3")
foreach ($Name in $Names) {
    Write-Host "Đang xử lý: $Name"
}

# Cách 2: Foreach qua pipeline
$Names | ForEach-Object {
    Write-Host "Đang xử lý đối tượng: $_"
}
```

### 4.5. Xử Lý Lỗi (Error Handling)
Để viết script DevOps tin cậy, bạn cần kiểm soát được lỗi xảy ra:

* **`$ErrorActionPreference = "Stop"`:**
  Tương đương với lệnh `set -e` trong Bash. Lệnh này cấu hình cho PowerShell dừng chạy script ngay lập tức nếu gặp bất kỳ lỗi không nghiêm trọng (Non-terminating error) nào.
* **Khối `Try - Catch`:**
  ```powershell
  $ErrorActionPreference = "Stop" # Bắt buộc phải có để lỗi chuyển thành Exception
  try {
      # Thực hiện lệnh có thể gây ra lỗi
      kubectl apply -f k8s/deployment.yaml
      Write-Host "Deploy thành công!" -ForegroundColor Green
  }
  catch {
      # Xử lý khi có lỗi xảy ra
      Write-Host "Đã có lỗi xảy ra trong quá trình deploy: $_" -ForegroundColor Red
      exit 1
  }
  ```

### 4.6. Xuất Dữ Liệu Đồng Bộ (Out-Host)
Trong PowerShell, đầu ra của tiến trình bên ngoài (như `docker`, `kubectl`) đi qua một luồng pipeline định dạng. Để tránh hiện tượng các dòng thông tin bị hiển thị lệch thứ tự hoặc đè lên nhau, chúng ta sử dụng `Out-Host` để bắt buộc dữ liệu in ra màn hình ngay lập tức:
```powershell
# Chạy đồng bộ và in kết quả ra màn hình console ngay lập tức
kubectl get pods | Out-Host
```

