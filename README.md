# Bonum Production Deployment

Bu loyiha **hojiyevschool.uz** domeni va **91.99.1.216** IP manzili uchun maxsus tayyorlangan.

## Oson o'rnatish (Deployment)

Serverga kirganingizdan so'ng, ushbu loyihani clone qiling va quyidagi scriptni ishga tushiring:

```bash
chmod +x setup_server.sh
./setup_server.sh
```

### Script nima qiladi?
1. `Docker` va `Docker-Compose`ni o'rnatadi (agar yo'q bo'lsa).
2. `Nginx`ni o'rnatadi va reverse proxy qilib sozlaydi.
3. Loyihani Docker konteynerlarida ishga tushiradi.
4. Ma'lumotlar bazasini (`migrate`) va static fayllarni (`collectstatic`) to'g'rilaydi.
5. Xohlasangiz, `Let's Encrypt` orqali bepul **HTTPS (SSL)** sertifikatini o'rnatib beradi.

## Muhim qadamlar

1. `.env.example` faylidan `.env` nusxasini oling va o'zgaruvchilarni (ayniqsa `SECRET_KEY`) kiriting:
   ```bash
   cp .env.example .env
   nano .env
   ```
2. Statik va Media fayllar Nginx tomonidan xizmat qilinishi uchun `docker-compose.yml`da volume-lar tayyorlangan.

## Qo'shimcha buyruqlar

- Konteynerlarni to'xtatish: `docker-compose down`
- Loglarni ko'rish: `docker-compose logs -f`
- Superuser yaratish: `docker-compose exec web python manage.py createsuperuser`
