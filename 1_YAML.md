# YAML & CI/CD Workflow Cheatsheet

Tài liệu này cung cấp hướng dẫn nhanh về cú pháp YAML, các từ khóa phổ biến trong GitHub Actions (dựa trên các từ khóa bạn đã liệt kê) và đối chiếu với GitLab CI/CD để bạn dễ dàng tự tìm hiểu.

---

## 📌 Mục Lục (Table of Contents)

- [1. Bản chất và Tính chất quan trọng của YAML](#1-bản-chất-và-tính-chất-quan-trọng-của-yaml)
  - [Các đặc trưng quan trọng của YAML](#các-đặc-trưng-quan-trọng-của-yaml)
- [2. Giải nghĩa các từ khóa CI/CD phổ biến (GitHub Actions)](#2-giải-nghĩa-các-từ-khóa-cicd-phổ-biến-github-actions)
  - [`name`](#name)
  - [`on`](#on)
  - [`jobs`](#jobs)
  - [`steps`](#steps)
  - [`run`](#run)
  - [`uses`](#uses)
  - [`with`](#with)
  - [`env`](#env)
  - [`needs`](#needs)
- [3. Bản đồ đối chiếu sang GitLab CI/CD](#3-bản-đồ-đối-chiếu-sang-gitlab-cicd)
- [4. Tài liệu chính thức (Official Documentation Docs)](#4-tài-liệu-chính-thức-official-documentation-docs)
- [5. Q&A (Câu hỏi thường gặp)](#5-qa-câu-hỏi-thường-gặp)

---

## 1. Bản chất và Tính chất quan trọng của YAML
**YAML** (viết tắt của *YAML Ain't Markup Language*) là một ngôn ngữ mã hóa dữ liệu dưới dạng văn bản (data serialization language), thường được dùng để cấu hình hệ thống, workflow, hoặc docker-compose.

### Các đặc trưng quan trọng của YAML
*   **Thụt lề bằng khoảng trắng (Indentation):** YAML sử dụng khoảng trắng (spaces) để phân cấp cấu trúc (cha-con).
    *   ⚠️ **Bắt buộc:** Phải dùng dấu cách (spaces), **không được dùng phím Tab**.
    *   Thông thường người ta dùng **2 khoảng trắng** cho mỗi cấp bậc thụt lề.
*   **Phân biệt chữ hoa/chữ thường (Case Sensitivity):** `env` khác với `Env` hay `ENV`.
*   **Cấu trúc Key-Value:** Được phân tách bởi dấu hai chấm và khoảng trắng `: ` (ví dụ: `name: Build App` - sau dấu `:` bắt buộc phải có một khoảng trắng).
*   **Danh sách (Lists/Arrays):** Được biểu diễn bằng dấu gạch ngang `-` thụt lề bằng nhau.
*   **Các kiểu dữ liệu cơ bản:**
    *   *Chuỗi (String):* Có thể viết thường không cần nháy, hoặc dùng nháy đơn `'...'`, nháy kép `"..."`.
    *   *Boolean:* `true`/`false` hoặc `yes`/`no`.
    *   *Số (Integer/Float):* `12`, `3.14`.
    *   *Giá trị rỗng:* `null` hoặc để trống.
*   **Ký tự đặc biệt để viết nhiều dòng:**
    *   `|` (Literal Block Scalar): Giữ nguyên các ký tự xuống dòng (thường dùng cho các khối lệnh shell dài).
    *   `>` (Folded Block Scalar): Gộp các dòng lại thành một dòng dài duy nhất phân tách bằng khoảng trắng.

---

## 2. Giải nghĩa các từ khóa CI/CD phổ biến (GitHub Actions)
Các từ khóa bạn đề cập như `name`, `on`, `jobs`, `steps`, `run`, `uses`, `with`, `env`, `needs` là các từ khóa chuẩn của **GitHub Actions** (được cấu hình trong thư mục `.github/workflows/`).

Dưới đây là chi tiết từng từ khóa:

### `name`
*   **Ý nghĩa:** Tên của workflow, job, hoặc step.
*   **Mục đích:** Giúp hiển thị trực quan trên giao diện web của GitHub để dễ theo dõi quá trình chạy.
*   **Ví dụ:**
    ```yaml
    name: Docker Build and Push
    ```

### `on`
*   **Ý nghĩa:** Định nghĩa các sự kiện (trigger events) kích hoạt workflow tự động chạy.
*   **Ví dụ:** Chạy khi có code push lên nhánh `main`, hoặc khi tạo pull request, hoặc cho phép chạy thủ công (`workflow_dispatch`).
    ```yaml
    on:
      push:
        branches: [ main, dev ]
      workflow_dispatch: # Cho phép nhấn nút chạy thủ công trên web
    ```

### `jobs`
*   **Ý nghĩa:** Nhóm các công việc (job) cần thực hiện trong workflow. Các job mặc định sẽ **chạy song song** với nhau (trừ khi được cấu hình phụ thuộc qua `needs`).
*   **Ví dụ:**
    ```yaml
    jobs:
      build-code:
        runs-on: ubuntu-latest
        steps:
          # các bước...
      deploy-app:
        runs-on: ubuntu-latest
        steps:
          # các bước...
    ```

### `steps`
*   **Ý nghĩa:** Danh sách các bước tuần tự sẽ được thực thi bên trong một job cụ thể.
*   **Ví dụ:** Mỗi step có thể chạy lệnh terminal hoặc gọi một Action có sẵn.
    ```yaml
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Install dependencies
        run: npm install
    ```

### `run`
*   **Ý nghĩa:** Chạy các câu lệnh terminal (shell command) trên runner máy ảo.
*   **Ví dụ:** Chạy một hoặc nhiều lệnh shell.
    ```yaml
    - name: Run Tests
      run: |
        npm run lint
        npm run test
    ```

### `uses`
*   **Ý nghĩa:** Gọi và sử dụng một Action đã được viết sẵn (từ GitHub Marketplace hoặc thư mục local).
*   **Ví dụ:** Sử dụng action checkout code hoặc login vào Docker Registry.
    ```yaml
    - name: Login to DockerHub
      uses: docker/login-action@v3
    ```

### `with`
*   **Ý nghĩa:** Cung cấp các tham số đầu vào (inputs) cho Action được gọi ở phần `uses`.
*   **Ví dụ:** Truyền username và password khi login Docker.
    ```yaml
    - name: Login to DockerHub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
    ```

### `env`
*   **Ý nghĩa:** Khai báo các biến môi trường (environment variables) cho workflow, job, hoặc step cụ thể.
*   **Ví dụ:**
    ```yaml
    env:
      NODE_ENV: production
      PORT: 3000
    ```

### `needs`
*   **Ý nghĩa:** Tạo sự phụ thuộc giữa các job. Job hiện tại chỉ bắt đầu chạy khi các job được liệt kê trong `needs` đã chạy thành công.
*   **Ví dụ:** Job `deploy` chỉ chạy sau khi job `build` và job `test` hoàn thành.
    ```yaml
    jobs:
      build:
        runs-on: ubuntu-latest
      test:
        runs-on: ubuntu-latest
      deploy:
        needs: [build, test] # Chỉ chạy khi build và test thành công
        runs-on: ubuntu-latest
    ```

---

## 3. Bản đồ đối chiếu sang GitLab CI/CD
Nếu dự án của bạn chuyển sang sử dụng **GitLab CI/CD** (cấu hình trong file `.gitlab-ci.yml`), các từ khóa trên sẽ có các từ khóa tương đương hoặc tương đồng như sau:

| Khái niệm / Chức năng | GitHub Actions (YAML) | GitLab CI/CD (YAML) |
| :--- | :--- | :--- |
| **Kích hoạt sự kiện** | `on` | `rules`, `only`, `except` |
| **Nhóm công việc** | `jobs` | Định nghĩa trực tiếp ở root level, phân cấp qua `stages` |
| **Thứ tự thực thi** | Chạy song song mặc định | Chạy tuần tự theo `stages` (ví dụ: build -> test -> deploy) |
| **Các lệnh thực thi** | `run` | `script` |
| **Gọi thư viện/Action**| `uses` | `image` (chạy trong docker image) hoặc dùng `include` |
| **Tham số truyền vào** | `with` | N/A (thường truyền qua biến môi trường hoặc cấu hình image) |
| **Biến môi trường** | `env` | `variables` |
| **Phụ thuộc giữa các job**| `needs` | `needs` (tương tự GitHub) hoặc phụ thuộc ngầm định qua `stage` |

---

## 4. Tài liệu chính thức (Official Documentation Docs)
Để học sâu hơn và tự tra cứu khi cần, bạn có thể truy cập các liên kết tài liệu chính thức sau:

### Tài liệu chính thức của GitHub Actions
*   [GitHub Actions Syntax Reference](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions): Tài liệu chi tiết nhất về tất cả các từ khóa (`on`, `jobs`, `steps`, `env`, `needs`,...).
*   [Understanding GitHub Actions](https://docs.github.com/en/actions/about-github-actions/understanding-github-actions): Khái niệm cơ bản, cách hoạt động của workflow, runner, job, step.

### Tài liệu chính thức của GitLab CI/CD
*   [GitLab CI/CD YAML syntax reference](https://docs.gitlab.com/ee/ci/yaml/index.html): Hướng dẫn chi tiết tất cả các từ khóa trong file `.gitlab-ci.yml` (như `script`, `stage`, `needs`, `rules`, `image`, `variables`,...).
*   [GitLab CI/CD Tutorial for Beginners](https://docs.gitlab.com/ee/ci/quick_start/): Hướng dẫn nhanh bắt đầu viết file CI/CD đầu tiên trên GitLab.

### Tài liệu & Công cụ về YAML
*   [YAML Official Specification](https://yaml.org/spec): Trang chủ đặc tả kỹ thuật của YAML.
*   [Learn YAML in Y Minutes](https://learnxinyminutes.com/docs/yaml/): Hướng dẫn nhanh cú pháp YAML qua ví dụ trực quan trong 5 phút.
*   [YAML Lint](http://www.yamllint.com/): Công cụ kiểm tra cú pháp file YAML online để xem có bị lỗi thụt dòng hay định dạng không.

---

## 5. Q&A (Câu hỏi thường gặp)

### ❓ Tại sao dùng `git add .` nhưng không thêm được file YAML cấu hình workflow?
* **Hiện tượng:** Bạn tạo file `.github/workflows/1_pipeline.yaml` ở thư mục gốc của dự án, nhưng khi đứng ở thư mục con (ví dụ: `first_pipeline/`) và chạy `git add .`, file workflow vẫn ở trạng thái *Untracked* và không được đẩy lên GitHub.
* **Nguyên nhân:** Dấu chấm `.` trong câu lệnh `git add .` đại diện cho **thư mục hiện tại và các thư mục con của nó**. Nếu bạn đang ở trong thư mục con, Git sẽ bỏ qua các file nằm ở thư mục cha hoặc thư mục đồng cấp bên ngoài. Điều này hoàn toàn không liên quan đến cấu hình `.gitignore`.
* **Cách giải quyết:** 
  * Di chuyển terminal về thư mục gốc của dự án trước khi chạy `git add .`.
  * Hoặc sử dụng lệnh dưới đây từ thư mục con để thêm toàn bộ thay đổi ở mọi vị trí trong dự án:
    ```bash
    git add :/
    ```
    *(Ký hiệu `:/` chỉ thị cho Git thêm mọi thay đổi tính từ thư mục gốc của repository).*
  * Hoặc sử dụng `git add -A` (hoặc `git add --all`).

### ❓ Tại sao file workflow đã hiện trên giao diện GitHub nhưng khi push code lên nhánh chính (`main`) vẫn không chạy ("0 workflow runs")?
* **Hiện tượng:** Bạn đã push file `.github/workflows/1_pipeline.yaml` thành công, tên workflow đã xuất hiện trong danh sách của tab Actions trên GitHub nhưng khi bạn push thêm commit mới, workflow vẫn không tự chạy và báo *"This workflow has no runs yet"*.
* **Nguyên nhân:** Lỗi **thụt lề (indentation) không chuẩn** trong file YAML. 
  * Cú pháp YAML quy chuẩn sử dụng thụt dòng bằng **khoảng trắng (spaces)** với số lượng chẵn (thường là 2 hoặc 4 spaces) để phân cấp cha-con. 
  * Nếu bạn thụt lề lẻ (ví dụ: 1 space hoặc 3 spaces), trình đọc YAML của GitHub Actions có thể bị lỗi phân tích cú pháp trigger (`on.push.branches`) hoặc cấu trúc jobs, dẫn đến việc bỏ qua trigger kích hoạt chạy mà không báo lỗi cú pháp rõ ràng.
* **Cách khắc phục & Lưu ý:**
  * **Tuyệt đối không dùng phím Tab** để thụt lề trong YAML.
  * Hãy luôn tuân thủ nguyên tắc thụt lề đồng nhất (nên là số chẵn khoảng trắng). Ví dụ:
    ```yaml
    name: CI pipeline       # Cấp 0 (không thụt lề)
    on:                     # Cấp 0
      push:                 # Cấp 1 (thụt 2 spaces)
        branches:           # Cấp 2 (thụt 4 spaces)
          - main            # Cấp 3 (thụt 6 spaces)
    ```
  * Hãy cài đặt thêm extension kiểm tra cú pháp YAML trên editor của bạn (như extension **YAML** của Red Hat trên VS Code) hoặc dán code vào các trang online như [YAML Lint](http://www.yamllint.com/) để xác thực trước khi commit.

### ❓ Tại sao workflow chạy bị báo lỗi không tìm thấy `package.json` hoặc bị treo (timeout)?
* **Hiện tượng:** Khi workflow chạy, bước cài đặt thư viện (`npm install`) báo lỗi không tìm thấy file hoặc ứng dụng bị chạy treo liên tục không kết thúc được.
* **Nguyên nhân:**
  * Mặc định, mọi lệnh trong phần `run` của workflow đều được thực thi tại **thư mục gốc của repository**. Nếu project Node.js của bạn nằm trong một thư mục con (ví dụ: `first_pipeline/`), runner sẽ không thấy `package.json` để cài đặt.
  * Nếu chạy ở thư mục gốc chứa project lớn có sẵn lệnh `npm start` để khởi chạy server (như Express), lệnh này sẽ chạy liên tục và treo tiến trình của GitHub Actions cho đến khi hết thời gian chạy tối đa (timeout).
  * Trong thư mục con của bạn có thể không định nghĩa script `start` mà định nghĩa script khác (ví dụ: `"run": "node index.js"`).
* **Cách khắc phục:**
  * Thêm cấu hình `working-directory` vào cấp độ `jobs` để trỏ toàn bộ câu lệnh về thư mục con:
    ```yaml
    jobs:
      build:
        runs-on: ubuntu-latest
        defaults:
          run:
            working-directory: ./first_pipeline # Chỉ định thư mục con
    ```
  * Thay đổi lệnh chạy app cho phù hợp với script được khai báo trong `package.json` của thư mục đó (ví dụ: dùng `npm run run` thay vì `npm start` nếu không định nghĩa script `start`).

### ❓ Các dòng lệnh `actions/checkout@v4` và `actions/setup-node@v3` trong file workflow dùng để làm gì?
* **Giải nghĩa chi tiết:**
  * **`uses: actions/checkout@v4`**: Đây là Action chính thức của GitHub để **tải mã nguồn (checkout)** từ repository của bạn vào máy ảo (runner). Mặc định, máy ảo khởi động lên hoàn toàn trống trơn; bước này giúp lấy code của dự án về máy ảo để có thể chạy kiểm thử hoặc build.
  * **`uses: actions/setup-node@v3`**: Action này dùng để cài đặt môi trường chạy **Node.js** trên máy ảo.
  * **`with:`**: Truyền các tham số cấu hình cho Action setup-node:
    * `node-version: '16'`: Chỉ định phiên bản Node.js cần cài đặt (trong trường hợp này là phiên bản 16).
    * `cache: 'npm'`: Bật tính năng lưu bộ nhớ đệm (caching) cho các file tải về từ thư mục `node_modules`. Giúp các lần chạy workflow sau này nhanh hơn rất nhiều vì không cần tải lại tất cả gói thư viện từ internet.
    * `cache-dependency-path: './package-lock.json'`: Đường dẫn chỉ tới file `package-lock.json`. GitHub Actions sẽ dựa vào file này để biết khi nào danh sách thư viện có sự thay đổi (để tạo cache mới hoặc tiếp tục sử dụng cache cũ).



