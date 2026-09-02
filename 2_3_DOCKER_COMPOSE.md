# 🐳 Hướng Dẫn Sử Dụng Docker Compose & Khởi Tạo Dự Án Với Docker Init

Tài liệu này giải thích tại sao nên sử dụng Docker Compose, quy trình tự động hóa cấu hình bằng `docker init` cho dự án React (Vite), cách tinh chỉnh cấu hình cho môi trường phát triển (Development) hỗ trợ Hot Reload và bảng tra cứu các câu lệnh Docker Compose thường dùng.

---

## 📌 Mục Lục (Table of Contents)

- [1. Tại Sao Nên Dùng Docker Compose?](#1-tại-sao-nên-dùng-docker-compose)
  - [Giải pháp: Docker Compose](#giải-pháp-docker-compose)
- [2. Sử Dụng `docker init` Để Tự Động Khởi Tạo Docker](#2-sử-dụng-docker-init-để-tự-động-khởi-tạo-docker)
  - [Các Bước Thực Hiện Chi Tiết](#các-bước-thực-hiện-chi-tiết)
  - [Các Tệp Tin Được Tự Động Tạo Ra](#các-tệp-tin-được-tự-động-tạo-ra)
  - [Lưu ý đặt tên tham khảo (`_Init` / `_init`)](#lưu-ý-đặt-tên-tham-khảo-init-init)
- [3. Cấu Hình Dự Án React (Vite) Cho Môi Trường Development](#3-cấu-hình-dự-án-react-vite-cho-môi-trường-development)
  - [3.1. Cấu hình Vite lắng nghe ở IP `0.0.0.0`](#31-cấu-hình-vite-lắng-nghe-ở-ip-0000)
  - [3.2. Cấu hình Polling Hot Reload trên Windows (WSL2 / Hyper-V)](#32-cấu-hình-polling-hot-reload-trên-windows-wsl2-hyper-v)
- [4. Xây Dựng Cấu Hình Dev Tùy Biến (Custom Config)](#4-xây-dựng-cấu-hình-dev-tùy-biến-custom-config)
  - [4.1. Tệp `dockerfile` Tự Cấu Hình](#41-tệp-dockerfile-tự-cấu-hình)
  - [4.2. Tệp `compose.yaml` Tự Cấu Hình](#42-tệp-composeyaml-tự-cấu-hình)
- [5. Vòng Đời Của Container & Cách Kết Nối Lại Khi Sử Dụng Sau Này](#5-vòng-đời-của-container-cách-kết-nối-lại-khi-sử-dụng-sau-này)
  - [5.1. Các Trạng Thái Vòng Đời của Docker Compose](#51-các-trạng-thái-vòng-đời-của-docker-compose)
  - [5.2. Hướng Dẫn Từng Bước Kết Nối Lại Sau Lần Chạy Đầu Tiên](#52-hướng-dẫn-từng-bước-kết-nối-lại-sau-lần-chạy-đầu-tiên)
  - [5.3. Khởi Tạo Nhiều Container & Cấu Hình Tên Image/Container Trong Compose](#53-khởi-tạo-nhiều-container-cấu-hình-tên-imagecontainer-trong-compose)
- [6. Bảng Tra Cứu Các Lệnh Docker Compose Thường Dùng](#6-bảng-tra-cứu-các-lệnh-docker-compose-thường-dùng)
- [7. Giải Thích Chi Tiết Các Trường Cấu Hình Trong YAML (Compose Specs)](#7-giải-thích-chi-tiết-các-trường-cấu-hình-trong-yaml-compose-specs)
  - [7.1. Nhóm Cấu Hình Cho Dịch Vụ Core (Core Services)](#71-nhóm-cấu-hình-cho-dịch-vụ-core-core-services)
  - [7.2. Nhóm Cấu Hình Đa Container Nâng Cao (Multi-Container / Database Specs)](#72-nhóm-cấu-hình-đa-container-nâng-cao-multi-container-database-specs)
  - [7.3. Nhóm Khai Báo Toàn Cục (Top-level Declarations)](#73-nhóm-khai-báo-toàn-cục-top-level-declarations)

---

## 1. Tại Sao Nên Dùng Docker Compose?

Khi làm việc với Docker cơ bản (sử dụng Docker CLI thông thường), chu trình xây dựng và chạy ứng dụng thường qua các bước thủ công phức tạp:
1. Build image: `docker build -t react-docker .`
2. Chạy container với port mapping, mount volume và cấu hình môi trường: 
   ```bash
   docker run -p 5173:5173 -v "$(pwd):/app" -v /app/node_modules react-docker
   ```

Khi dự án trở nên phức tạp hơn (ví dụ: cần thêm cơ sở dữ liệu PostgreSQL, cache Redis, backend API, v.v.), việc quản lý này sẽ gặp rất nhiều bất cập:
* **Quá nhiều bước thủ công:** Phải nhớ và chạy hàng loạt câu lệnh `docker run` dài dòng.
* **Quản lý khó khăn:** Rất khó để cấu hình thủ công hệ thống mạng nội bộ (`Docker Network`) để các container kết nối được với nhau, hoặc tạo ổ đĩa chia sẻ dữ liệu (`Docker Volume`).
* **Không đồng bộ:** Các thành viên khác trong team phải tự gõ lại các câu lệnh run với tham số cấu hình riêng, dễ dẫn đến lỗi môi trường khác biệt.

### Giải pháp: Docker Compose
**Docker Compose** là một công cụ giúp định nghĩa và quản lý đa container (multi-container) cho ứng dụng Docker. Toàn bộ cấu hình về **dịch vụ (services), mạng (networks), và phân vùng ổ đĩa (volumes)** sẽ được khai báo rõ ràng trong duy nhất một tệp tin cấu hình định dạng YAML (thường đặt tên là `compose.yaml` hoặc `docker-compose.yml`).

> [!TIP]
> Thay vì phải chạy thủ công 10 container bằng 10 lệnh khác nhau, với Docker Compose bạn chỉ cần chạy duy nhất một câu lệnh:
> ```bash
> docker compose up
> ```
> Docker Compose sẽ tự động dựng mạng, cấp phát volume, build image và khởi chạy toàn bộ hệ thống theo đúng thứ tự được khai báo.

---

## 2. Sử Dụng `docker init` Để Tự Động Khởi Tạo Docker

Docker cung cấp lệnh `docker init` để quét thư mục mã nguồn hiện tại, tự động nhận diện công nghệ đang dùng (Node.js, Python, Go, Rust, v.v.) và sinh ra các file cấu hình Docker mẫu chuẩn hóa.

### Các Bước Thực Hiện Chi Tiết

#### Bước 1: Khởi tạo dự án Vite (nếu làm từ đầu)
Di chuyển vào thư mục mong muốn và tạo dự án React + Vite:
```bash
npm create vite@latest 2_3_React_Docker_Compose
# Chọn framework: React
# Chọn variant: TypeScript / JavaScript
```
Sau đó cài đặt thư viện cục bộ:
```bash
cd 2_3_React_Docker_Compose
npm install
```

#### Bước 2: Chạy lệnh `docker init`
Trong thư mục gốc của dự án chứa `package.json`, chạy lệnh:
```bash
docker init
```

#### Bước 3: Điền các thông số cấu hình tương tác
Docker CLI sẽ hiển thị các câu hỏi gợi ý, bạn hãy cấu hình theo các bước sau:

1. **What application platform does your project use?**
   * *Lựa chọn:* Nhấn Enter để chọn **`Node`** (Docker tự động phát hiện qua tệp `package.json`).
2. **What version of Node do you want to use?**
   * *Lựa chọn:* Nhấn Enter để chọn phiên bản Node hiện hành đề xuất.
3. **Which package manager do you want to use?**
   * *Lựa chọn:* Nhấn Enter để chọn **`npm`** (hoặc chọn yarn/pnpm nếu dự án của bạn dùng chúng).
4. **Do you want to run "npm run build" before starting your server?**
   * *Lựa chọn:* Gõ **`No`** (vì trong môi trường phát triển development, chúng ta muốn chạy trực tiếp mã nguồn thông qua dev server Vite để cập nhật code nhanh, thay vì phải build tĩnh ra thư mục `dist`).
5. **What command do you want to use to start the app?**
   * *Lựa chọn:* Điền **`npm run dev`** (lệnh khởi chạy dev server của Vite).
6. **What port does your server listen on?**
   * *Lựa chọn:* Điền **`5173`** (cổng mặc định của Vite).

---

### Các Tệp Tin Được Tự Động Tạo Ra

Sau khi hoàn tất các bước trên, Docker sẽ tạo ra 4 tệp tin:
1. [`Dockerfile`](./2_3_React_Docker_Compose/Dockerfile): Chứa các bước chỉ dẫn đóng gói ứng dụng.
2. [`.dockerignore`](./2_3_React_Docker_Compose/.dockerignore): Khai báo danh sách các file/folder không đưa vào Docker build context (như `node_modules`).
3. [`compose.yaml`](./2_3_React_Docker_Compose/compose.yaml): Tệp cấu hình dịch vụ chạy bằng Docker Compose.
4. [`README.Docker.md`](./2_3_React_Docker_Compose/README.Docker.md): Hướng dẫn nhanh cách vận hành container vừa tạo.

### Lưu ý đặt tên tham khảo (`_Init` / `_init`)
Mẫu cấu hình được sinh ra bởi `docker init` mặc định được tối ưu cho chạy Production hoặc chạy cơ bản. Để phục vụ việc học tập, tham chiếu và tự cấu hình nâng cao cho môi trường Dev (Hot Reload, phân quyền tối ưu), chúng ta nên:
* Đổi tên `Dockerfile` mặc định thành [`Dockerfile_Init`](./2_3_React_Docker_Compose/Dockerfile_Init).
* Đổi tên `compose.yaml` mặc định thành [`compose_Init.yaml`](./2_3_React_Docker_Compose/compose_Init.yaml).

*Từ đó, chúng ta sẽ tự viết lại tệp `dockerfile` và `compose.yaml` tùy biến theo nhu cầu phát triển.*

---

## 3. Cấu Hình Dự Án React (Vite) Cho Môi Trường Development

Để chạy ứng dụng React (Vite) mượt mà trong Docker container và hỗ trợ **Hot Reload (sửa code máy host, UI tự cập nhật)**, chúng ta cần thực hiện các cấu hình lặp lại từ bài trước nhưng cực kỳ quan trọng:

### 3.1. Cấu hình Vite lắng nghe ở IP `0.0.0.0`
Mặc định Vite chỉ chạy trên `localhost` (`127.0.0.1`) của container, khiến máy host không kết nối được. Cần chỉnh sửa script khởi chạy trong [`package.json`](./2_3_React_Docker_Compose/package.json):
```json
"scripts": {
  "dev": "vite --host 0.0.0.0"
}
```
Hoặc cấu hình trực tiếp vào [`vite.config.ts`](./2_3_React_Docker_Compose/vite.config.ts):
```typescript
export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 5173
  }
})
```

### 3.2. Cấu hình Polling Hot Reload trên Windows (WSL2 / Hyper-V)
Nếu bạn lập trình trên Windows và mount thư mục vào Linux container, cơ chế bắt sự kiện thay đổi file mặc định của hệ điều hành có thể không hoạt động. Ta cần bật cơ chế quét định kỳ (polling) trong [`vite.config.ts`](./2_3_React_Docker_Compose/vite.config.ts):
```typescript
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    watch: {
      usePolling: true, // Ép Vite quét tệp tin định kỳ để nhận diện sửa code từ Windows host
    },
  },
})
```

---

## 4. Xây Dựng Cấu Hình Dev Tùy Biến (Custom Config)

Dưới đây là nội dung chi tiết của tệp `dockerfile` và `compose.yaml` tùy biến được thiết kế dành riêng cho môi trường lập trình (Development) có phân quyền bảo mật cao:

### 4.1. Tệp `dockerfile` Tự Cấu Hình
Lưu tại: [`2_3_React_Docker_Compose/dockerfile`](./2_3_React_Docker_Compose/dockerfile)
```dockerfile
# Sử dụng base image nhẹ Alpine
FROM node:20-alpine

# Tạo user phi root 'app' để nâng cao tính bảo mật
RUN addgroup app && adduser -S -G app app
USER app

WORKDIR /app

# Tách biệt việc cài dependencies để tận dụng Docker Cache Layer
COPY package*.json ./

# Khắc phục lỗi phân quyền khi mount volume sau này
USER root
RUN chown -R app:app .
USER app

# Cài đặt toàn bộ dependencies
RUN npm install

# Copy mã nguồn còn lại
COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev"]
```

> [!NOTE]
> **Giải thích chi tiết các câu lệnh quan trọng trong `dockerfile` trên:**
>
> 1. **Cơ chế tạo User & Group phi Root (`addgroup` & `adduser`):**
>    * `RUN addgroup app`: Tạo một nhóm (group) hệ thống mới có tên là `app`.
>    * `adduser -S -G app app`: Tạo một user hệ thống mới tên `app` và đưa user này vào nhóm `app` (`-G app`).
>    * **Option `-S`:** Viết tắt của `--system` (Alpine Linux), tạo user hệ thống chuyên dụng chạy tiến trình nền, không có mật khẩu và không thể đăng nhập shell tương tác nhằm nâng cao bảo mật.
>
> 2. **Cơ chế phân quyền sở hữu (`chown`):**
>    * `RUN chown -R app:app .`:
>      * `chown`: Lệnh thay đổi quyền sở hữu (owner:group) của file hoặc thư mục.
>      * `-R`: Viết tắt của Recursive (đệ quy), áp dụng cho toàn bộ file và thư mục con bên trong thư mục hiện tại (`.`).
>      * `app:app`: Chỉ định chủ sở hữu mới là user `app` và group `app`.
>    * 💡 **Lưu ý kỹ thuật:** Lệnh này cần chạy khi Dockerfile đang ở quyền `root` (trước câu lệnh `USER app`), hoặc có thể tối ưu bằng flag `COPY --chown=app:app package*.json ./`. Nếu chuyển sang `USER app` quá sớm, user này sẽ không đủ đặc quyền để chạy `chown`.
>
> 3. **Cơ chế Layer Cache (Tách `package*.json` ra trước) & Thời điểm tác dụng thực tế:**
>    * **Kịch bản 1: Cách làm thông thường (`COPY . .` rồi `RUN npm install`)**
>      * Khi bạn chỉ sửa 1 dòng code trong `src/App.jsx`: `COPY . .` làm vỡ cache $\rightarrow$ `RUN npm install` bắt buộc phải chạy lại từ đầu $\rightarrow$ **Mất 2-5 phút chờ tải lại thư viện.**
>    * **Kịch bản 2: Cách làm chuẩn (Tách `package*.json` ra trước)**
>      * Khi bạn sửa code trong `src/App.jsx`: File `package.json` không đổi $\rightarrow$ **Tái sử dụng Cache** của bước `npm install` $\rightarrow$ Chỉ copy lại file code ở bước `COPY . .` $\rightarrow$ **Build xong chỉ trong 1-2 giây!**
>    * ⚡ **LƯU Ý QUAN TRỌNG VỀ THỜI ĐIỂM TÁC DỤNG:**
>      * ❌ **Lúc gõ code hàng ngày (Container ĐANG CHẠY):** File `dockerfile` hoàn toàn "ngủ đông". Code bạn sửa cập nhật ngay lên trình duyệt là nhờ **Bind Mount (`- .:/app`)** trong `compose.yaml`. Hoàn toàn không có lệnh `COPY` hay `npm install` nào chạy lại lúc này.
>      * ✅ **Lúc Build lại Image (Tạo mới từ đầu):** Khi bạn cài thêm thư viện mới, đổi branch, dựng container lần đầu hoặc đưa project sang máy khác. Đây mới chính là lúc 3 dòng code này phát huy tác dụng giúp tái sử dụng Cache, rút ngắn thời gian khởi tạo từ vài phút xuống còn vài giây.

### 4.2. Tệp `compose.yaml` Tự Cấu Hình
Lưu tại: [`2_3_React_Docker_Compose/compose.yaml`](./2_3_React_Docker_Compose/compose.yaml)
```yaml
services:
  web:
    build:
      context: .
      dockerfile: dockerfile
    ports:
      - "5173:5173"
    volumes:
      - .:/app
      - /app/node_modules
```

> [!IMPORTANT]
> **Giải thích bản chất cơ chế `volumes` & Vòng đời dữ liệu (Phân biệt Build time vs Run time):**
>
> 1. **Dòng 1: `- .:/app` (Bind Mount - Có dấu hai chấm `:`):**
>    * Tạo "đường ống trực tiếp" đồng bộ thư mục mã nguồn từ máy thật (`.`) vào `/app` trong container. Nhờ đó sửa code ở máy host thì container nhận ngay lập tức.
>    * *Điểm yếu:* Nó sẽ đè toàn bộ thư mục máy thật lên `/app`, làm che mất thư mục `node_modules` đã cài trong container.
>
> 2. **Dòng 2: `- /app/node_modules` (Anonymous Volume - KHÔNG có dấu hai chấm `:`):**
>    * Tạo một ổ đĩa ảo cô lập trên Docker host cho riêng đường dẫn `/app/node_modules`, đóng vai trò là "vùng cấm" bảo vệ thư viện chuẩn Linux không bị máy host đè hỏng.
>
> 🔄 **Bản chất thực tế (Trả lời câu hỏi về thời điểm chạy `npm install`):**
> * ❌ **Hiểu lầm phổ biến:** Nghĩ rằng Docker tạo volume trống rồi mới chạy `RUN npm install` bên trong volume đó.
> * ✅ **Thực tế diễn ra qua 2 giai đoạn rõ rệt:**
>   * **Giai đoạn 1 (Lúc Build Image):** Đọc `dockerfile`, chạy `RUN npm install` và nén toàn bộ thư viện vào Image tại `/app/node_modules`. Lúc này Volumes chưa hề tồn tại.
>   * **Giai đoạn 2 (Lúc Chạy Container từ Compose):** Docker tạo Anonymous Volume (ban đầu là ổ đĩa trống). **Phép thuật của Docker:** Khi gắn một volume trống vào đường dẫn đã có sẵn dữ liệu từ trong Image (`/app/node_modules`), Docker sẽ **tự động COPY toàn bộ thư viện từ Image đổ sang Volume ảo đó** để cất giữ an toàn.
>   * *Khi nào cập nhật lại?* Chỉ khi bạn sửa `package.json` và build lại Image (Giai đoạn 1 diễn ra lại $\rightarrow$ tạo Image mới $\rightarrow$ Docker lại copy thư viện mới vào volume ở Giai đoạn 2).

> [!TIP]
> **Bản chất Hot Reload & Giải tỏa các nhầm lẫn về Ports / Args / Chạy lại Image:**
>
> 1. **Do đâu code thay đổi ở máy host thì trong Docker cập nhật theo (Hot Reload)?**
>    * **Nhờ Bind Mount (`- .:/app`)**: Container "nhìn xuyên qua" ổ cứng máy host và dùng chung file vật lý. Khi bạn bấm Ctrl+S ở VS Code, file trong container đổi ngay với độ trễ bằng 0.
>    * **Nhờ Dev Server (Vite) File Watcher**: Tiến trình `npm run dev` túc trực 24/7 trong container theo dõi file thay đổi và tự động biên dịch, đẩy giao diện mới lên trình duyệt mà không cần F5.
>
> 2. **Giải tỏa các nhầm lẫn kỹ thuật thường gặp:**
>    * **Docker KHÔNG chạy lại Image:** Image sau khi build xong là một khối tĩnh đóng băng. Container đang chạy chỉ là một tiến trình (process). Container không bao giờ tự động "nhìn lại image để chạy lại".
>    * **Port (`ports: - "5173:5173"`)**: Chỉ làm nhiệm vụ đục một lỗ xuyên qua firewall container để máy host truy cập `localhost:5173`. Port **không** có chức năng đồng bộ code hay cập nhật image.
>    * **Args (`ARG`)**: Chỉ là các biến môi trường được truyền vào một lần duy nhất lúc build image (Build-time) và kết thúc nhiệm vụ ngay sau khi build xong.

---

## 5. Vòng Đời Của Container & Cách Kết Nối Lại Khi Sử Dụng Sau Này

Nhiều người mới học Docker thường thắc mắc: **"Sau này muốn chạy lại dự án, có cần chạy lệnh `docker compose up` nữa hay không? Nếu chạy lại thì nó có tạo image và container mới làm nặng máy không?"**

Câu trả lời là: **Docker Compose rất thông minh**. Nó sẽ kiểm tra xem cấu hình (`Dockerfile`, `compose.yaml`) và code của bạn có thay đổi gì ảnh hưởng đến build không. Nếu không, nó sẽ tái sử dụng lại các container cũ hoặc chỉ khởi động lại chúng mà không tạo mới hoàn toàn làm nặng máy.

Tuy nhiên, để tối ưu và làm việc chuyên nghiệp, bạn nên hiểu rõ vòng đời dưới đây để có cách vận hành phù hợp:

### 5.1. Các Trạng Thái Vòng Đời của Docker Compose

1. **`docker compose up`**: 
   * **Nhiệm vụ:** Tạo mới và khởi chạy toàn bộ dịch vụ (tạo container, card mạng, volume).
   * **Khi chạy lại:** Nếu các container đã tồn tại và đang ở trạng thái dừng, lệnh này sẽ chỉ **khởi động lại** chúng chứ không tạo mới (không nhân đôi container).
2. **`docker compose stop`**:
   * **Nhiệm vụ:** Tạm dừng các container đang chạy. Lúc này, container vẫn tồn tại dưới dạng tắt (Exited) chứ không bị xóa đi. Cấu hình và dữ liệu của container vẫn được giữ nguyên.
3. **`docker compose start`**:
   * **Nhiệm vụ:** Khởi động lại các container đang ở trạng thái dừng (`stop`) mà **không cần quét lại cấu hình** hay dựng lại mạng ảo. Lệnh này chạy cực nhanh.
4. **`docker compose down`**:
   * **Nhiệm vụ:** Dừng và **xóa bỏ hoàn toàn** các container cũng như mạng ảo (networks) đã tạo. 
   * *Lưu ý:* Vì chúng ta đã cấu hình `volumes` chia sẻ dữ liệu mã nguồn và dữ liệu database, nên kể cả khi chạy `down` để xóa sạch container, dữ liệu của bạn ở máy thật vẫn hoàn toàn an toàn. Lần tới chạy `docker compose up`, Docker sẽ tạo container mới và mount lại dữ liệu cũ sang rất sạch sẽ.

---

### 5.2. Hướng Dẫn Từng Bước Kết Nối Lại Sau Lần Chạy Đầu Tiên

Sau khi đã tắt máy tính hoặc dừng dự án, ở lần làm việc tiếp theo, bạn có hai cách dễ dàng để bật lại và tiếp tục code:

#### Cách 1: Sử Dụng Giao Diện Docker Desktop (Khuyên Dùng Cho Dev)
1. **Mở phần mềm Docker Desktop** trên máy tính của bạn.
2. Chọn menu **Containers** ở thanh công cụ bên trái.
3. Bạn sẽ thấy một nhóm container (Stack) được đặt tên theo dự án của bạn (ví dụ: `2_3_react_docker_compose`).
4. Nhấn nút **Play (Start)** ở góc phải của nhóm container đó để bật toàn bộ dịch vụ lên.
5. Khi trạng thái chuyển sang màu xanh lá cây (**Running**), mở trình duyệt và truy cập `http://localhost:5173` để tiếp tục làm việc.
6. **Để truy cập vào Shell (Terminal) của container:** Click vào container của dịch vụ `web` đang chạy, sau đó chọn tab **Terminal** ở thanh menu ngang phía trên. Bạn sẽ vào thẳng Shell Linux để chạy các lệnh debug.

#### Cách 2: Sử Dụng Dòng Lệnh Docker CLI (Nhanh & Tiện)
Mở Terminal tại thư mục dự án chứa file `compose.yaml`:
* **Để bật lại dự án nhanh:**
  ```bash
  docker compose start
  ```
  *(Hoặc bạn vẫn có thể gõ `docker compose up -d` để chạy nền, Docker sẽ tự nhận diện container cũ đã có và chỉ khởi động lại nó).*
* **Để truy cập vào Terminal (Shell) tương tác bên trong container:**
  ```bash
  docker compose exec web sh
  ```
  *(Lệnh này sẽ khởi tạo một phiên terminal `sh` bên trong container của dịch vụ `web` đang chạy. Bạn có thể sử dụng các lệnh Linux như `ls`, `pwd`, `cd`, v.v. để kiểm tra file hệ thống của container).*
* **Để tạm dừng dự án khi code xong:**
  ```bash
  docker compose stop
  ```

---

### 5.3. Khởi Tạo Nhiều Container & Cấu Hình Tên Image/Container Trong Compose

Trong thực tế, bạn sẽ gặp tình huống muốn nhân bản hoặc chạy nhiều container cùng một lúc từ một cấu hình Docker Compose (ví dụ: chạy nhiều container web để test cân bằng tải Load Balancing, hoặc chạy các môi trường test độc lập). 

#### 1. Cách Tạo Nhiều Container Từ Cùng Một Dịch Vụ (Scaling Containers)
Docker Compose hỗ trợ một cơ chế cực kỳ mạnh mẽ để nhân bản container từ một dịch vụ đã định nghĩa sẵn thông qua cờ `--scale`.

* **Câu lệnh thực hiện:**
  ```bash
  docker compose up -d --scale web=3
  ```
  *Lệnh trên sẽ ra lệnh cho Docker Compose khởi chạy **3 container song song** đại diện cho dịch vụ `web`.*

* ⚠️ **Lưu ý quan trọng về Xung Đột Cổng (Port Conflict):**
  Nếu trong file `compose.yaml` bạn đang hardcode cổng mạng dạng:
  ```yaml
  ports:
    - "5173:5173"
  ```
  Lệnh `--scale` sẽ **báo lỗi thất bại**. Lý do là vì container thứ nhất sẽ chiếm cổng `5173` của máy thật, khiến container thứ hai và thứ ba không thể ánh xạ vào cổng đó được nữa.
  * **Giải pháp:** Để scale thành công, bạn phải bỏ cấu hình cổng host cố định trong file `compose.yaml` (ví dụ chỉ viết `- "5173"` để Docker tự cấp phát cổng ngẫu nhiên ở máy thật), hoặc sử dụng một dịch vụ Reverse Proxy (như Nginx/Traefik) đứng trước để phân phối traffic.

#### 2. Cách Tạo Nhiều Container Bằng Cách Định Nghĩa Dịch Vụ Mới
Nếu bạn muốn chạy các container riêng lẻ trỏ chung vào cùng một mã nguồn/image nhưng có cấu hình cổng hoặc biến môi trường khác nhau, cách đơn giản nhất là khai báo thêm các dịch vụ (Services) mới trong file `compose.yaml`:

```yaml
services:
  web-instance-1:
    build:
      context: .
      dockerfile: dockerfile
    ports:
      - "5173:5173" # Container 1 chạy cổng 5173
    volumes:
      - .:/app
      - /app/node_modules

  web-instance-2:
    build:
      context: .
      dockerfile: dockerfile
    ports:
      - "5174:5173" # Container 2 chạy cổng 5174 ở máy thật
    volumes:
      - .:/app
      - /app/node_modules
```
*Khi chạy `docker compose up`, Docker Compose sẽ tự động tạo ra **2 container độc lập** chạy song song mà không bị xung đột cổng ở máy thật.*

---

#### 3. Quy Tắc Đặt Tên & Cách Cấu Hình Tên Image/Container Trong Compose

Khi mới chạy `docker init` và sinh ra cấu hình mặc định, Docker Compose tự động đặt tên cho Image và Container của bạn theo các quy tắc ngầm định dưới đây. Bạn hoàn toàn có thể tự cấu hình lại các tên này trong file `compose.yaml`.

##### A. Quy Tắc Đặt Tên Mặc Định
* **Tên của Container (Container Name):**
  Mặc định được đặt theo cấu trúc: `<tên_thư_mục_gốc>-<tên_dịch_vụ>-<chỉ_số>`
  * *Ví dụ:* Thư mục dự án của bạn tên là `2_3_React_Docker_Compose`, dịch vụ khai báo là `web` $\rightarrow$ Tên container mặc định khi chạy lên sẽ là: `2_3_react_docker_compose-web-1`.
* **Tên của Image (Image Name):**
  Mặc định khi build qua compose, image sẽ có tên dạng: `<tên_thư_mục_gốc>-<tên_dịch_vụ>` (ví dụ: `2_3_react_docker_compose-web`).

##### B. Cách Cấu Hình Tên Theo Ý Muốn (Custom Naming)
Để cấu hình tên tùy chỉnh thay vì dùng tên mặc định dựa trên thư mục gốc, bạn thêm các trường cấu hình sau vào tệp `compose.yaml`:

1. **Thay đổi tên Container:** Sử dụng trường **`container_name`** tại cấp dịch vụ.
2. **Thay đổi tên Image được build:** Sử dụng trường **`image`** ngay bên dưới tên dịch vụ (nằm cùng cấp với `build`).
3. **Thay đổi tiền tố dự án (Project Name Prefix):** Sử dụng trường **`name`** ở cấp cao nhất (Top-level) của file `compose.yaml` hoặc định nghĩa biến `COMPOSE_PROJECT_NAME` trong file `.env`.

*Ví dụ cấu hình tùy chỉnh hoàn chỉnh:*
```yaml
name: my-react-app # Đổi tên Project Name (thay thế cho tên thư mục gốc)

services:
  web:
    container_name: react-dev-container # Đổi tên Container cố định theo ý muốn
    build:
      context: .
      dockerfile: dockerfile
    image: amalkin39/react-docker:dev   # Chỉ định tên và tag của Image khi build ra
    ports:
      - "5173:5173"
    volumes:
      - .:/app
      - /app/node_modules
```

*   **Kết quả:** Khi chạy `docker compose up`, container sẽ được đặt tên chính xác là `react-dev-container`, và image build ra sẽ mang tên `amalkin39/react-docker:dev` sẵn sàng để push lên Docker Hub.

---

## 6. Bảng Tra Cứu Các Lệnh Docker Compose Thường Dùng

Khi làm việc với Docker Compose, hãy mở Terminal tại thư mục chứa tệp `compose.yaml` và sử dụng các câu lệnh sau:

| Lệnh | Chức năng |
| :--- | :--- |
| **`docker compose up`** | Khởi tạo mạng, volume, tạo container và chạy các service ở chế độ hiển thị log (Foreground). |
| **`docker compose up -d`** | Chạy các container dưới nền (Detached mode), giải phóng terminal. |
| **`docker compose up --build`** | Ép buộc Docker Compose build lại image mới trước khi khởi chạy container (dùng khi bạn sửa `package.json` hoặc `Dockerfile`). |
| **`docker compose down`** | Dừng toàn bộ container và xóa bỏ container, card mạng ảo được tạo ra bởi lệnh `up`. |
| **`docker compose down -v`** | Dừng container và xóa luôn cả các volume được khai báo (xóa sạch dữ liệu lưu trữ tạm). |
| **`docker compose ps`** | Liệt kê danh sách các container đang được quản lý bởi file compose này và trạng thái của chúng. |
| **`docker compose logs`** | Xem logs đầu ra của toàn bộ các service. |
| **`docker compose logs -f <service_name>`** | Theo dõi trực tiếp logs của một service cụ thể (ví dụ: `docker compose logs -f web`). |
| **`docker compose exec <service_name> <command>`** | Chạy một dòng lệnh tương tác trực tiếp bên trong container (ví dụ mở terminal: `docker compose exec web sh`). |

---

## 7. Giải Thích Chi Tiết Các Trường Cấu Hình Trong YAML (Compose Specs)

Dưới đây là phần phân tích chi tiết ý nghĩa và vai trò của từng trường (key/field) xuất hiện trong cả file tự cấu hình và file gợi ý mặc định (`compose_Init.yaml`):

### 7.1. Nhóm Cấu Hình Cho Dịch Vụ Core (Core Services)

*   **`services:`** (Trường cấp cao nhất - Top-level)
    *   *Ý nghĩa:* Khai báo danh sách các dịch vụ (các container độc lập) cấu thành nên ứng dụng của bạn. Mỗi dịch vụ dưới mục này tương đương với một thực thể container chạy riêng biệt.
*   **`web:` / `server:`**
    *   *Ý nghĩa:* Tên định danh của dịch vụ do bạn tự đặt (ví dụ: `web`, `server`, `api`, `database`). Tên này cũng chính là tên máy chủ (Hostname) trong mạng ảo của Docker, giúp các container dễ dàng liên lạc với nhau.
*   **`build:`**
    *   *Ý nghĩa:* Chỉ định các thông số để Docker tự động xây dựng (build) image mới từ mã nguồn local.
    *   **`context:`** Chỉ định thư mục chứa ngữ cảnh build (Build Context), thông thường là `.` (thư mục hiện tại).
    *   **`dockerfile:`** Chỉ định tên tệp Dockerfile cần dùng (ví dụ: `dockerfile` hoặc `Dockerfile.dev`). Nếu bỏ qua, mặc định Docker sẽ tự tìm tệp có tên là `Dockerfile`.
*   **`ports:`**
    *   *Ý nghĩa:* Cấu hình ánh xạ cổng mạng từ máy Host vào Container (Port Forwarding), viết dưới dạng danh sách (`-`).
    *   *Cú pháp:* `- "<cổng_máy_host>:<cổng_trong_container>"` (ví dụ: `5173:5173`).
*   **`volumes:`**
    *   *Ý nghĩa:* Khai báo chia sẻ dữ liệu hoặc gắn thư mục ảo (Mounting) giữa máy Host và Container.
    *   *Sự khác biệt về cú pháp (Dựa trên dấu hai chấm `:`):* 
        *   `- .:/app`: (Có dấu `:`) Đây là **Bind Mount**, ánh xạ thư mục máy host vào container để đồng bộ mã nguồn (Hot Reload).
        *   `- /app/node_modules`: (Không có dấu `:`) Đây là **Anonymous Volume**, tạo vùng nhớ độc lập do Docker quản lý nhằm làm "ngoại lệ" chặn máy host đè lên thư mục thư viện của container.
*   **`environment:`**
    *   *Ý nghĩa:* Thiết lập các biến môi trường (Environment Variables) truyền vào bên trong container khi khởi chạy.
    *   *Ví dụ:* `NODE_ENV: production` hoặc các biến kết nối database.

---

### 7.2. Nhóm Cấu Hình Đa Container Nâng Cao (Multi-Container / Database Specs)

Trong tệp gợi ý `compose_Init.yaml`, Docker cung cấp một khung mẫu kết nối với cơ sở dữ liệu PostgreSQL. Dưới đây là ý nghĩa các trường cấu hình nâng cao trong ví dụ đó:

*   **`depends_on:`**
    *   *Ý nghĩa:* Khai báo sự phụ thuộc giữa các dịch vụ. Docker Compose sẽ khởi chạy các dịch vụ phụ thuộc trước.
    *   *Ví dụ:* Dịch vụ `web` phụ thuộc vào `db` $\rightarrow$ Docker khởi chạy container `db` trước rồi mới khởi chạy `web`.
    *   **`condition: service_healthy`:** Yêu cầu container phụ thuộc không chỉ chạy lên mà còn phải vượt qua bài kiểm tra sức khỏe (`healthcheck`) thì dịch vụ chính mới được khởi động.
*   **`db:`**
    *   *Ý nghĩa:* Tên dịch vụ cơ sở dữ liệu (PostgreSQL).
*   **`image:`**
    *   *Ý nghĩa:* Thay vì tự build từ Dockerfile, trường này chỉ định Docker tải trực tiếp image đã được đóng gói sẵn từ Docker Hub (ví dụ: `image: postgres`).
*   **`restart: always`**
    *   *Ý nghĩa:* Chính sách tự khởi động lại. Nếu container bị lỗi đột ngột (crash) hoặc dịch vụ Docker daemon trên máy chủ khởi động lại, container này sẽ tự động chạy lại.
*   **`user: postgres`**
    *   *Ý nghĩa:* Chỉ định tiến trình bên trong container chạy dưới quyền user nào (trong ví dụ là user `postgres`).
*   **`secrets:` (Cấp dịch vụ)**
    *   *Ý nghĩa:* Gắn các tệp bảo mật (như password, chứng chỉ) vào container một cách an toàn tại runtime mà không cần lưu trực tiếp mật khẩu vào code hoặc biến môi trường.
*   **`expose:`**
    *   *Ý nghĩa:* Khai báo cổng mạng mà dịch vụ này lắng nghe, nhưng **chỉ cho phép giao tiếp nội bộ giữa các container trong mạng ảo** chứ không ánh xạ cổng ra ngoài máy host. Trong ví dụ là cổng `5432` của PostgreSQL.
*   **`healthcheck:`**
    *   *Ý nghĩa:* Cấu hình kiểm tra trạng thái sức khỏe tự động của dịch vụ để đảm bảo container đang hoạt động đúng.
    *   **`test:`** Câu lệnh chạy bên trong container để test (ví dụ chạy `pg_isready` để check Postgres).
    *   **`interval:`** Khoảng thời gian giữa các lần check (ví dụ cứ `10s` check 1 lần).
    *   **`timeout:`** Thời gian tối đa chờ câu lệnh kiểm tra phản hồi (ví dụ `5s`).
    *   **`retries:`** Số lần thử lại thất bại liên tiếp trước khi đánh giá container là "unhealthy" (ví dụ `5` lần).

---

### 7.3. Nhóm Khai Báo Toàn Cục (Top-level Declarations)

Được viết ở cấp ngoài cùng của file YAML, ngang hàng với `services:`:

*   **`volumes:` (Top-level)**
    *   *Ý nghĩa:* Khai báo các **Named Volume** (ổ đĩa ảo có tên độc lập). Các volume này sẽ được Docker quản lý riêng biệt và dữ liệu sẽ không bị mất đi ngay cả khi container bị xóa hoàn toàn.
    *   *Ví dụ:* `db-data:` dùng để lưu trữ lâu dài dữ liệu PostgreSQL.
*   **`secrets:` (Top-level)**
    *   *Ý nghĩa:* Định nghĩa nguồn của các tệp bảo mật (Secrets) cung cấp cho các dịch vụ bên trên.
    *   *Ví dụ:* `db-password: file: db/password.txt` định nghĩa secret tên `db-password` được đọc từ tệp tin `db/password.txt` ở máy host.

