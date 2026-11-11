متجر الرومانسية للألعاب الزوجية — حزمة البداية

الملفات:
- index.html: واجهة المتجر العربية RTL، الأقسام، المنتجات، السلة، إتمام الطلب، الفاتورة، رورو المساعدة.
- admin.html: لوحة إدارة المنتجات والأقسام والطلبات والإعدادات والزوار.
- supabase-setup.sql: إنشاء الجداول والسياسات ومساحة الصور.
- robots.txt و sitemap.xml: ملفات تهيئة محركات البحث (يجب تعديل النطاق).

مهم قبل النشر:
1) شغّل supabase-setup.sql في SQL Editor.
2) في Supabase Authentication > Users أنشئ مستخدم إدارة ببريد وكلمة مرور.
3) انسخ User UID ثم نفّذ:
   insert into public.admin_users (user_id) values ('UUID-HERE') on conflict do nothing;
4) في index.html و admin.html استبدل PASTE_YOUR_sb_publishable_KEY_HERE بمفتاح sb_publishable العام فقط.
5) لا تضع sb_secret أو service_role في أي ملف HTML ولا ترسله لأحد.
6) ارفع index.html إلى جذر الاستضافة، و admin.html بجانبه (رابط /admin.html).
7) غيّر YOUR-DOMAIN.example في canonical و sitemap.xml و robots.txt إلى نطاقك الفعلي.

حدود النسخة:
- رورو هنا مساعد محلي يبحث في أسماء وأوصاف المنتجات الموجودة في قاعدة البيانات، وليس نموذج ذكاء اصطناعي سحابي خارق. ربط ذكاء اصطناعي حقيقي يتطلب خادماً آمناً ومفتاح API محفوظاً في الخادم.
- عداد الزوار يسجل زيارات الصفحة عند نجاح الاتصال، وليس تحليلات فريدة أو مضمونة 100%.
- الفاتورة تظهر بعد تسجيل الطلب ويمكن طباعتها/حفظها PDF من المتصفح.
- لا يوجد بوابة دفع إلكتروني في هذه النسخة.
- Google لا يضمن فهرسة الموقع بمجرد رفع sitemap؛ أضف النطاق إلى Google Search Console واطلب الفهرسة.
