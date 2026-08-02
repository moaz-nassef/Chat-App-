# 🏗️ Hungry App - الـ System Architecture الكامل

> **تاريخ الإنشاء:** 28 يوليو 2026
> **الهدف:** توثيق كامل لهيكل المشروع، الـ Design Patterns، والـ System Design لنقلها لمشاريع أخرى

---

## 📑 الفهرس
1. [هيكل المشروع (Project Structure)](#1-هيكل-المشروع-project-structure)
2. [الـ Design Patterns المستخدمة](#2-الـ-design-patterns-المستخدمة)
3. [System Design - تدفق البيانات](#3-system-design---تدفق-البيانات)
4. [كل صفحة وفائدتها في المشروع](#4-كل-صفحة-وفائدتها-في-المشروع)
5. [الـ UI/UX Style](#5-الـ-uiux-style)
6. [المنهجية (Methodology)](#6-المنهجية-methodology)
7. [قائمة الـ Packages المستخدمة](#7-قائمة-الـ-packages-المستخدمة)

---

## 1. 📁 هيكل المشروع (Project Structure)

```
Hungry-BLOC/
├── lib/
│   ├── main.dart                               # نقطة الدخول
│   ├── splash.dart                             # شاشة البداية (Splash)
│   ├── root.dart                               # الـ Bottom Navigation + الـ 4 شاشات الرئيسية
│   │
│   ├── core/                                   # ⚙️ الطبقة المشتركة (Core)
│   │   ├── constants/
│   │   │   └── app_colors.dart                 # ألوان الثيم (primary = #103e34)
│   │   │   └── api_endpoints.dart              # Dead code - endpoints قديمة
│   │   ├── network/
│   │   │   ├── dio_client.dart                 # Dio configuration + Interceptors (Bearer Token)
│   │   │   ├── api_service.dart                # CRUD generic methods (GET/POST/PUT/DELETE)
│   │   │   ├── api_error.dart                  # Model الخطأ
│   │   │   └── api_exceptions.dart             # معالجة أخطاء Dio
│   │   ├── utils/
│   │   │   ├── pref_helper.dart                # SharedPreferences (token storage)
│   │   │   └── validators.dart                 # Validation (فاضي حالياً)
│   │   └── di_container.dart                   # 🧩 GetIt Dependency Injection
│   │
│   ├── features/                               # 📦 كل Feature له مجلد مستقل
│   │   ├── auth/                               # 🔐 Authentication Feature
│   │   │   ├── cubit/
│   │   │   │   ├── auth_cubit.dart             #     - AuthCubit
│   │   │   │   └── auth_state.dart             #     - States (Initial, Loading, Authenticated, Unauthenticated, Error)
│   │   │   ├── data/
│   │   │   │   ├── auth_repo.dart              #     - Login, Signup, Logout, AutoLogin, Guest
│   │   │   │   └── user_model.dart             #     - UserModel (name, email, token, visa, address)
│   │   │   ├── views/
│   │   │   │   ├── login_view.dart             #     - صفحة تسجيل الدخول
│   │   │   │   ├── signup_view.dart            #     - صفحة إنشاء حساب
│   │   │   │   └── profile_view.dart           #     - صفحة الملف الشخصي
│   │   │   └── widgets/
│   │   │       ├── custom_btn.dart             #     - زر مخصص (Login/Signup/Guest)
│   │   │       └── custom_user_txt_field.dart  #     - Input field خاص بالبروفايل
│   │   │
│   │   ├── home/                               # 🏠 المنتجات الرئيسية
│   │   │   ├── cubit/
│   │   │   │   ├── home_cubit.dart             #     - HomeCubit (categories, search, filter)
│   │   │   │   └── home_state.dart             #     - States (Initial, Loading, Loaded, Error)
│   │   │   ├── data/
│   │   │   │   ├── repo/
│   │   │   │   │   └── product_repo.dart       #     - getProducts, searchProducts
│   │   │   │   └── models/
│   │   │   │       ├── product_model.dart      #     - ProductModel (id, name, image, price, rate)
│   │   │   │       └── topping_model.dart      #     - ToppingModel (ملغي حالياً)
│   │   │   ├── views/
│   │   │   │   └── home_view.dart              #     - الصفحة الرئيسية
│   │   │   └── widgets/
│   │   │       ├── card_item.dart              #     - بطاقة المنتج (صورة + اسم + وصف + تقييم)
│   │   │       ├── user_header.dart            #     - Header المستخدم (Hello, name + صورة)
│   │   │       ├── search_field.dart           #     - حقل البحث
│   │   │       └── food_catrgory.dart          #     - الفئات (Horizontal Scroll)
│   │   │
│   │   ├── productDetail/                      # 🔍 تفاصيل المنتج
│   │   │   ├── cubit/
│   │   │   │   ├── product_details_cubit.dart  #     - ProductDetailsCubit (spicy + add to cart)
│   │   │   │   └── product_details_state.dart  #     - States (toppings, options, addStatus)
│   │   │   ├── views/
│   │   │   │   └── product_details_view.dart   #     - صفحة تفاصيل المنتج
│   │   │   └── widgets/
│   │   │       ├── spicy_slider.dart           #     - Slider مستوى الحرارة
│   │   │       └── topping_card.dart           #     - بطاقة الإضافات (ملغية حالياً)
│   │   │
│   │   ├── cart/                               # 🛒 سلة التسوق
│   │   │   ├── cubit/
│   │   │   │   ├── cart_cubit.dart             #     - CartCubit (CRUD + quantities)
│   │   │   │   └── cart_state.dart             #     - States (Initial, Loading, Loaded, Error)
│   │   │   ├── data/
│   │   │   │   ├── cart_repo.dart              #     - addToCart, getCartData, removeCartItem
│   │   │   │   └── cart_model.dart             #     - CartModel, CartData, CartItemModel
│   │   │   ├── views/
│   │   │   │   └── cart_view.dart              #     - صفحة السلة
│   │   │   └── widgets/
│   │   │       └── cart_item.dart              #     - عنصر في السلة (صورة + اسم + كميات + Remove)
│   │   │
│   │   ├── checkout/                           # 💳 الدفع
│   │   │   ├── cubit/
│   │   │   │   ├── checkout_cubit.dart         #     - CheckoutCubit (payment method + place order)
│   │   │   │   └── checkout_state.dart         #     - States (Initial, Ready)
│   │   │   ├── views/
│   │   │   │   └── checkout_view.dart          #     - صفحة الدفع
│   │   │   └── widgets/
│   │   │       ├── order_details_widget.dart   #     - تفاصيل الطلب (Order, Taxes, Fees, Total)
│   │   │       └── success_dailog.dart         #     - Dialog نجاح الدفع
│   │   │
│   │   └── orderHistory/                       # 📋 تاريخ الطلبات
│   │       ├── cubit/
│   │       │   ├── order_history_cubit.dart    #     - OrderHistoryCubit
│   │       │   └── order_history_state.dart    #     - States (Initial, Loading, Loaded, Error)
│   │       ├── data/
│   │       │   ├── order_repo.dart             #     - placeOrder, getOrders
│   │       │   └── order_model.dart            #     - OrderModel
│   │       └── views/
│   │           └── order_history_view.dart     #     - صفحة تاريخ الطلبات
│   │
│   └── shared/                                 # ♻️ Widgets مشتركة (قابلة لإعادة الاستخدام)
│       ├── custom_text.dart                    #     - CustomText widget
│       ├── custom_button.dart                  #     - CustomButton widget
│       ├── custom_txtfield.dart                #     - CustomTxtfield (مع show/hide password)
│       ├── custom_snack.dart                   #     - SnackBar مخصص للخطأ
│       ├── glass_container.dart                #     - Frosted Glass Effect
│       ├── glass_nav.dart                      #     - Glassmorphism Bottom Nav Bar
│       └── visa_form_field_widget.dart         #     - 3D Card Flip form للفيزا
│
├── assets/
│   ├── logo/              # SVG Logo
│   ├── splash/            # صور Splash
│   ├── lottie/            # Lottie animations (burger.json)
│   ├── detail/            # صور تفاصيل
│   ├── icon/              # أيقونات
│   ├── banner/            # Banner images
│   ├── 3dModel/           # 3D Models
│   └── appIcon/           # App Icon
│
├── API_MIGRATION_GUIDE.md # دليل تغيير API (Sonic → Masalamile)
└── MIGRATION_PLAN.md      # خطة الترحيل بالتفصيل
```

---

## 2. 🎯 الـ Design Patterns المستخدمة

### 🔷 BLoC Pattern (Cubit) — State Management الرئيسي

كل Feature ليها:
- **Cubit** → بيحتوي على الـ Business Logic
- **State** → `sealed class` مع States مختلفة
- كل View بتستخدم `BlocProvider` + `BlocBuilder` / `BlocListener`

#### قائمة الـ Cubits والـ States:

| Feature | Cubit | States |
|---------|-------|--------|
| Auth | `AuthCubit` | `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError` |
| Home | `HomeCubit` | `HomeInitial`, `HomeLoading`, `HomeLoaded` (allProducts, filteredProducts, selectedCategoryIndex, searchQuery), `HomeError` |
| Product Detail | `ProductDetailsCubit` | `ProductDetailsInitial`, `ProductDetailsLoading`, `ProductDetailsLoaded` (toppings, options, spicy, selectedToppings, selectedOptions, addStatus), `ProductDetailsError` |
| Cart | `CartCubit` | `CartInitial`, `CartLoading`, `CartLoaded` (cart, quantities, isActionInProgress), `CartError` |
| Checkout | `CheckoutCubit` | `CheckoutInitial`, `CheckoutReady` (selectedMethod, isPlacingOrder, orderPlaced, orderError) |
| Order History | `OrderHistoryCubit` | `OrderHistoryInitial`, `OrderHistoryLoading`, `OrderHistoryLoaded` (orders list), `OrderHistoryError` |

### 🔷 Repository Pattern

```
طبقات البيانات (Data Flow):
┌────────────┐
│   View     │  ← Flutter UI (Widgets)
├────────────┤
│   Cubit    │  ← State Management
├────────────┤
│   Repo     │  ← Business Logic + Data Parsing
├────────────┤
│ ApiService │  ← Network Layer (Dio HTTP)
├────────────┤
│   Dio      │  ← HTTP Client
└────────────┘
```

### 🔷 Dependency Injection (GetIt)

- **ملف:** `lib/core/di_container.dart`
- `sl` = `GetIt.instance`
- **تنقسم لـ 3 أنواع:**

```dart
// Singletons (instance واحد طول عمر التطبيق)
sl.registerLazySingleton<ApiService>(() => ApiService());
sl.registerLazySingleton<AuthRepo>(() => AuthRepo(sl<ApiService>()));
sl.registerLazySingleton<ProductRepo>(() => ProductRepo(sl<ApiService>()));
sl.registerLazySingleton<CartRepo>(() => CartRepo(sl<ApiService>()));
sl.registerLazySingleton<OrderRepo>(() => OrderRepo(sl<ApiService>()));
sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthRepo>()));
sl.registerLazySingleton<CartCubit>(() => CartCubit(sl<CartRepo>()));

// Factories (instance جديد كل مرة)
sl.registerFactory<HomeCubit>(() => HomeCubit(sl<ProductRepo>()));
sl.registerFactory<ProductDetailsCubit>(() => ProductDetailsCubit(sl<ProductRepo>(), sl<CartCubit>()));
sl.registerFactory<CheckoutCubit>(() => CheckoutCubit(sl<OrderRepo>(), sl<CartCubit>()));
sl.registerFactory<OrderHistoryCubit>(() => OrderHistoryCubit(sl<OrderRepo>(), sl<AuthRepo>()));
```

### 🔷 Feature-First Architecture (مجلد لكل Feature)

```
كل Feature = مجلد مستقل قابل للفصل والترحيل لأي مشروع تاني
كل Feature جواه 4 أقسام:
  ├── cubit/     # State Management
  ├── data/      # Repo + Models
  ├── views/     # الصفحات
  └── widgets/   # Components
```

---

## 3. 🧩 System Design - تدفق البيانات

### تدفق الـ Request من الـ UI للـ API:

```
👤 User Presses Button (مثلاً: "Login")
    ↓
View ينادي: context.read<AuthCubit>().login(email, password)
    ↓
AuthCubit: emit(AuthLoading())
    ↓
AuthCubit: _authRepo.login(email, password)
    ↓
AuthRepo: apiService.post('/user/login', body)
    ↓
ApiService: _dioClient.dio.post(endpoint, data: body)
    ↓
Dio Interceptor: يضيف Bearer Token تلقائياً
    ↓
HTTP Request → Backend API
    ↓
JSON Response ← Backend
    ↓
ApiService: return response.data
    ↓
AuthRepo: يحول الـ JSON لـ UserModel, يحفظ الـ Token
    ↓
AuthCubit: emit(AuthAuthenticated(user))
    ↓
View: BlocListener يسمع الـ State ويعمل Navigate
```

### تدفق الخطأ (Error Handling):

```
Dio Exception
    ↓
ApiExceptions.handleError(e)
    ↓
ApiError (message + statusCode)
    ↓
Repo يرمي ApiError
    ↓
Cubit يمسك الـ ApiError: emit(AuthError(e.message))
    ↓
View: BlocListener → customSnack(error.message)
```

### تكوين الـ Dio Client:

```dart
DioClient {
  BaseOptions(
    baseUrl: 'https://masalamile-backend.onrender.com/api/',
    headers: {"Content-Type": 'application/json'},
  )

  Interceptors:
    - Bearer Token Interceptor (يقرأ من SharedPreferences ويضيفه في الـ Header)
    - (معلق) LogInterceptor للـ Debugging
}
```

---

## 4. 📄 كل صفحة وفائدتها في المشروع

### 1. **SplashView** (`lib/splash.dart`)
- **الرابط:** `/splash`
- **الفائدة:** شاشة البداية بتظهر لمدة 1 ثانية
- **الوظيفة:**
  - TweenAnimationBuilder (Scale للـ Logo + Translate للصورة)
  - Gradient خلفية (بتتدرج من Primary لشفاف)
  - BlocListener يسمع `AuthCubit`:
    - لو `AuthAuthenticated` أو `AuthUnauthenticated` → يروح لـ `Root()`
    - لو `AuthError` → يروح لـ `Root()` برضو
- **State Management:** `BlocListener<AuthCubit, AuthState>`

### 2. **LoginView** (`features/auth/views/login_view.dart`)
- **الرابط:** أول شاشة بعد الـ Splash
- **الفائدة:** تسجيل الدخول (Email + Password)
- **الوظيفة:**
  - Form validation (تحقق من الحقول الفاضية)
  - زر Login مع Loading indicator
  - زر Signup → ينتقل لـ `SignupView`
  - زر Guest → يدخل كضيف
  - SnackBar للأخطاء
- **State Management:** `BlocListener<AuthCubit, AuthState>` + `BlocBuilder`
- **الخلفية:** `glassContainer()` → Frosted Glass مع Lottie animation برجر

### 3. **SignupView** (`features/auth/views/signup_view.dart`)
- **الرابط:** يتم الانتقال إليه من LoginView
- **الفائدة:** إنشاء حساب جديد (Name + Email + Password)
- **الوظيفة:**
  - 3 TextFields (Name, Email, Password)
  - زر Signup مع Loading
  - زر Login + Guest
- **State Management:** زى الـ Login
- **الخلفية:** `glassContainer()` نفس الـ Login

### 4. **ProfileView** (`features/auth/views/profile_view.dart`)
- **الرابط:** التاب الرابع في الـ Bottom Nav
- **الفائدة:** عرض بيانات المستخدم وإدارتها
- **الوظيفة:**
  - عرض الصورة الشخصية (CircleAvatar)
  - Name, Email, Address (TextFields مقفولة حالياً)
  - بطاقة Debit Card (Visa)
  - زر Logout
  - Guest Mode → رسالة "Guest Mode" + زر "Go to Login"
  - Skeletonizer تحميل
  - RefreshIndicator للتحديث
- **ملاحظة:** `getProfileData()` بترجع null دلوقتي (API الجديد معندهاش `/profile`)

### 5. **HomeView** (`features/home/views/home_view.dart`)
- **الرابط:** التاب الأول في الـ Bottom Nav
- **الفائدة:** الصفحة الرئيسية - عرض المنتجات
- **الوظيفة:**
  - **Header:** اسم المستخدم + صورته (BlocBuilder من AuthCubit)
  - **SearchField:** بحث محلي (فلترة على الـ Client Side)
  - **FoodCategory:** Horizontal Scroll (All, Salad, Rolls, Noodles, Cake, Pure Veg)
  - **Products Grid:** `SliverGrid` مع `SliverGridDelegateWithMaxCrossAxisExtent`
    - `CardItem`: صورة + اسم + وصف + تقييم (نجوم) + قلب (مفضل)
    - Shimmer loading أثناء تحميل البيانات
  - الضغط على منتج → `Navigator.push` لـ `ProductDetailsView`
- **State Management:** `BlocProvider<HomeCubit>(create: ...loadProducts())` داخل الـ build

### 6. **ProductDetailsView** (`features/productDetail/views/product_details_view.dart`)
- **الرابط:** يتم الانتقال إليه من HomeView
- **الفائدة:** عرض تفاصيل المنتج وإضافته للسلة
- **الوظيفة:**
  - صورة المنتج كبيرة
  - **SpicySlider:** Slider لمستوى الحرارة (Cold → Hot)
  - سعر المنتج في الـ Bottom Sheet
  - زر **Add to Cart** مع 3 حالات:
    - `idle`: "Add To Cart"
    - `adding`: Spinne
    - `added`: "Added to Cart" (مش شغال تاني)
  - SnackBar عند النجاح/الخطأ
- **ملاحظة:** Toppings/Options ملغية حالياً (API جديد)

### 7. **CartView** (`features/cart/views/cart_view.dart`)
- **الرابط:** التاب التاني في الـ Bottom Nav
- **الفائدة:** عرض سلة التسوق
- **الوظيفة:**
  - قائمة العناصر في السلة (صور + اسم + وصف + كميات)
  - زراير **+** و **-** للكمية
  - زر **Remove** لحذف العنصر
  - **Badge** على أيقونة الـ Nav بار (عدد العناصر)
  - Floating Bottom Bar:
    - إجمالي السعر 🟢 Gradient
    - زر **Checkout** → يروح لـ `CheckoutView`
  - حالة Empty: "NO ITEMS ADEED YET"
  - Guest Mode → Empty state
- **State Management:** `BlocBuilder<CartCubit, CartState>` + `BlocBuilder<AuthCubit, AuthState>`

### 8. **CheckoutView** (`features/checkout/views/checkout_view.dart`)
- **الرابط:** يتم الانتقال إليه من CartView
- **الفائدة:** إتمام عملية الدفع
- **الوظيفة:**
  - **Order Summary:** Order, Taxes ($3.50), Delivery fees ($40.33), Total
  - **Payment Methods:**
    - Cash on Delivery (بطاقة سوداء)
    - Visa/Debit Card (بطاقة زرقاء)
    - إذا مفيش Visa → `VisaFormFieldWidget` (3D Card Flip)
  - Checkbox "Save card details"
  - **Bottom Sheet:** Total السعر + زر **Pay Now**
  - **Success Dialog:** بعد الدفع (CircleAvatar + علامة صح + رسالة)
- **State Management:** `BlocProvider<CheckoutCubit>` + `BlocListener`

### 9. **OrderHistoryView** (`features/orderHistory/views/order_history_view.dart`)
- **الرابط:** التاب التالت في الـ Bottom Nav
- **الفائدة:** عرض تاريخ الطلبات
- **الوظيفة:**
  - قائمة الطلبات (صورة + اسم + كمية + سعر)
  - زر **Order Again** (مش شغال فعلياً)
  - حالة Empty: "NO ORDERS RIGHT NOW"
  - Guest Mode → قائمة فاضية
  - CircularProgressIndicator أثناء التحميل
- **State Management:** `BlocProvider<OrderHistoryCubit>`

### 10. **Root** (`lib/root.dart`)
- **الرابط:** الشاشة الرئيسية بعد Auth
- **الفائدة:** الـ Container الرئيسي لكل التابات
- **الوظيفة:**
  - `IndexedStack` (بيحفظ State كل تاب)
  - `GlassBottomNavBar`:
    - 4 تابات: Home, Cart, History, Profile
    - AnimatedPill (دائرة بتتحرك مع التاب المختار)
    - AnimatedSwitcher للـ Icons
    - Badge على Cart icon (عدد العناصر)
  - `PopScope(canPop: false)` — منع الرجوع بـ Back
  - AnimationControllers للأيقونات (بتموت مع كل تاب)

---

## 5. 🎨 الـ UI/UX Style

| التقنية | الاستخدام | الملفات |
|---------|-----------|---------|
| **Glassmorphism** | خلفية Login/Signup (Blur + Gradient + Lottie) | `shared/glass_container.dart` |
| **Frosted Glass Nav Bar** | Bottom Nav مع BackdropFilter | `shared/glass_nav.dart` |
| **Lottie Animations** | خلفية الأكل (برجر متحرك) | `assets/lottie/burger.json` |
| **Shimmer/Skeletonizer** | Loading states بدل Spinner | في HomeView + ProfileView |
| **Cupertino Icons** | أيقونات iOS-style (Home, Cart, Person, etc) | في كل الصفحات |
| **SVG** | Logo (متجهات) | `assets/logo/logo.svg` |
| **Gradients** | خلفية Splash, Nav, Buttons, Checkout | في كل مكان |
| **3D Card Flip** | Visa form (قلب الكارت) | `shared/visa_form_field_widget.dart` |
| **Spicy Slider** | Slider مستوى الحرارة | `productDetail/widgets/spicy_slider.dart` |
| **ScreenUtil** | Responsive Design (base: 375x812) | `main.dart` → `ScreenUtilInit` |
| **AnimatedContainer** | Cart items animation | `cart/views/cart_view.dart` |
| **TweenAnimationBuilder** | Splash animations (Scale + Translate) | `splash.dart` |
| **BouncingScrollPhysics** | Scroll سلس في Cart | `cart/views/cart_view.dart` |
| **RepaintBoundary** | تحسين أداء الـ Grid | `home/views/home_view.dart` |

### ألوان الثيم (Theme):

| اللون | القيمة | الاستخدام |
|-------|--------|-----------|
| **Primary** | `#103e34` (أخضر غامق) | الخلفية الرئيسية، الأزرار، الأيقونات |
| **Secondary** | `#FFFFFF` (أبيض) | الخلفيات، النصوص العادية |
| **Accent** | `#EF2A39` (أحمر) | Checkbox |
| **Grey** | `#F3F4F6`, `#9CA3AF` | حدود، نصوص ثانوية |
| **Blue** | `#1a1a2e`, `#0f3460` | Visa Card |
| **Amber** | `#FFC107` | نجوم التقييم |

---

## 6. 🧠 المنهجية (Methodology) — الطريقة اللي بتشتغل بيها

```
┌─────────────────────────────────────────────────────────────────┐
│                    Feature-First Architecture                    │
│  كل Feature = مجلد مستقل (قابل للفصل والترحيل لأي مشروع تاني)   │
├─────────────────────────────────────────────────────────────────┤
│                    BLoC Pattern (Cubit)                         │
│  State Management باستخدام sealed classes                       │
├─────────────────────────────────────────────────────────────────┤
│                    Repository Pattern                           │
│  ApiService (Network) → Repo (Parsing) → Cubit (State)         │
├─────────────────────────────────────────────────────────────────┤
│                    Dependency Injection (GetIt)                  │
│  Service Locator: Singleton للـ Services, Factory للـ Cubits    │
├─────────────────────────────────────────────────────────────────┤
│                    Shared Widgets                               │
│  كل Widget مشترك (CustomText, CustomButton, etc) في shared/     │
├─────────────────────────────────────────────────────────────────┤
│                    BlocProvider في الـ Build                     │
│  كل View بتعمل BlocProvider في الـ build method (Factory Cubits)│
├─────────────────────────────────────────────────────────────────┤
│                    Error Handling موحد                           │
│  ApiError + ApiExceptions → كل Repos ترمي ApiError             │
├─────────────────────────────────────────────────────────────────┤
│                    Local Storage                                │
│  SharedPreferences → Token حفظ (PrefHelper)                     │
├─────────────────────────────────────────────────────────────────┤
│                    Glassmorphism UI Style                        │
│  Frosted Glass, Gradients, Lottie, Animations                   │
└─────────────────────────────────────────────────────────────────┘
```

### ⚡ الخطوات لو عايز تنقل Feature لمشروع تاني:

1. **انسخ مجلد الـ Feature كامل** (مثلاً `features/cart/`)
2. **انسخ الـ Core files** (`core/network/` + `core/di_container.dart` + `core/constants/`)
3. **انسخ Shared Widgets اللي محتاجه** (`shared/custom_text.dart`, `shared/custom_button.dart`, إلخ)
4. **عدل الـ `pubspec.yaml`** (ضيف الـ Packages: `flutter_bloc`, `get_it`, `dio`, `shared_preferences`, إلخ)
5. **عدل الـ `di_container.dart`** (سجل الـ Repos والـ Cubits)
6. **عدل الـ API endpoints** في `dio_client.dart` (baseUrl)
7. **ظبط الـ `main.dart`** (MultiBlocProvider + ScreenUtilInit)

### 📋 قائمة المحتويات اللي تقدر تنقلها (Portable):

| القطعة | وصفها | هل هي Portable؟ |
|--------|-------|:---:|
| **أي Feature كامل** (مجلد features/*) | مستقل بنفسه، ليه Cubit + Repo + Views + Widgets | ✅ |
| **Shared Widgets** (مجلد shared/) | CustomText, CustomButton, CustomTxtfield, إلخ | ✅ |
| **Core Network** (مجلد core/network/) | ApiService, DioClient, ApiError, ApiExceptions | ✅ |
| **DI Container** (core/di_container.dart) | GetIt setup (عدل الـ registrations) | ✅ |
| **PrefHelper** (core/utils/) | SharedPreferences wrapper | ✅ |
| **Constants** (core/constants/) | AppColors, ApiEndpoints | ✅ |
| **Glass Container** (shared/glass_container.dart) | Frosted Glass effect | ✅ |
| **Glass Nav Bar** (shared/glass_nav.dart) | Bottom Navigation | ✅ |
| **Visa Form Field** (shared/visa_form_field_widget.dart) | 3D Card Flip | ✅ |
| **Assets** (assets/) | Lottie, SVG, images | ✅ |

---

## 7. 📦 قائمة الـ Packages المستخدمة

| الـ Package | الاستخدام | ملف الـ Config |
|-------------|-----------|:---:|
| `flutter_bloc: ^9.1.0` | State Management (BLoC/Cubit) | `pubspec.yaml` |
| `get_it: ^8.0.3` | Dependency Injection | `pubspec.yaml` |
| `dio: ^5.9.0` | HTTP Client | `pubspec.yaml` |
| `shared_preferences: ^2.5.3` | Local Storage (Token) | `pubspec.yaml` |
| `flutter_screenutil: ^5.9.3` | Responsive Design | `pubspec.yaml` |
| `flutter_svg: ^2.2.1` | SVG images (Logo) | `pubspec.yaml` |
| `gap: ^3.0.1` | SizedBox اختصار (Gap()) | `pubspec.yaml` |
| `shimmer: ^3.0.0` | Shimmer loading effect | `pubspec.yaml` |
| `skeletonizer: ^2.1.3` | Skeleton loading | `pubspec.yaml` |
| `lottie: ^3.3.1` | Lottie animations | `pubspec.yaml` |
| `image_picker: ^1.2.0` | اختيار الصور (مستخدم في Profile قديماً) | `pubspec.yaml` |
| `animate_icons: ^2.0.0` | أيقونات متحركة | `pubspec.yaml` |
| `model_viewer_plus: ^1.9.3` | 3D Model viewer | `pubspec.yaml` |
| `cupertino_icons: ^1.0.8` | iOS-style icons | `pubspec.yaml` |
| `flutter_launcher_icons: ^0.14.3` | App Icon | `pubspec.yaml` |

---

## 🏁 الخلاصة

**الطريقة اللي بتشتغل بيها:**
> **"Feature-First Architecture + BLoC (Cubit) + Repository Pattern + GetIt DI + Glassmorphism UI"**

**ده نظام:**
- ✅ **منظم** — كل Feature في مجلد لوحده
- ✅ **قابل للترحيل** — تقدر تنقل أي Feature لمشروع تاني
- ✅ **قابل للتوسع** — تضيف Features جديدة بسهولة
- ✅ **Standard** — بيتبع best practices فلاتر
- ✅ **معزول** — كل Feature مش مرتبط بالتاني
- ✅ **Error Handling** موحد
- ✅ **Reusable Components** (CustomText, CustomButton, etc)

**وده الـ Template اللي تقدر تبدأ بيه أي مشروع جديد:**
```
new_project/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_colors.dart
│   │   ├── network/
│   │   │   ├── api_service.dart
│   │   │   ├── dio_client.dart
│   │   │   ├── api_error.dart
│   │   │   └── api_exceptions.dart
│   │   ├── utils/
│   │   │   └── pref_helper.dart
│   │   └── di_container.dart
│   ├── features/
│   │   └── [feature_name]/
│   │       ├── cubit/
│   │       ├── data/
│   │       ├── views/
│   │       └── widgets/
│   └── shared/
│       ├── custom_text.dart
│       ├── custom_button.dart
│       └── custom_txtfield.dart
└── pubspec.yaml
```


---

# 💬 Chat App - الـ System Architecture (النسخة المُحسّنة v2)

> **تاريخ التحديث:** 28 يوليو 2026
> **الهدف:** نفس الـ Template بتاع Hungry App لكن مطبق على Chat App حقيقي، مع إصلاح كل نقاط الضعف اللي اتسجلت فوق

**الفرق الجوهري عن Hungry App:** الشات **Realtime (Streams)** مش Request/Response — فكل الـ Cubits بتدير `StreamSubscription` وبتعمل `cancel()` في `close()`.

---

## 1. 📁 هيكل المشروع

```
Chat-App/
├── lib/
│   ├── main.dart                               # نقطة الدخول (Firebase init + DI + runApp)
│   ├── app.dart                                # ChatApp (Theme + Router + PresenceService)
│   ├── firebase_options.dart
│   │
│   ├── core/                                   # ⚙️ الطبقة المشتركة
│   │   ├── constants/
│   │   │   ├── app_colors.dart                 # ألوان الثيم (purple/blue identity)
│   │   │   ├── ai_constants.dart               # إعدادات الـ AI (model, userId, type)
│   │   │   └── firestore_paths.dart            # ⭐ كل الـ collections/fields في مكان واحد
│   │   ├── errors/
│   │   │   └── failure.dart                    # ⭐ sealed Failure (Auth/Firestore/Ai/Unknown) + mapping عربي
│   │   ├── utils/
│   │   │   ├── validators.dart                 # ⭐ Validation حقيقي (email/password/name/confirm)
│   │   │   └── date_formatter.dart             # HH:mm / Yesterday / Last seen
│   │   ├── theme/
│   │   │   └── app_theme.dart                  # ThemeData موحد
│   │   ├── router/
│   │   │   └── app_router.dart                 # ⭐ AppRoutes + onGenerateRoute + ChatViewArgs (typed)
│   │   ├── services/
│   │   │   └── presence_service.dart           # ⭐ online/offline مع App Lifecycle
│   │   └── di_container.dart                   # 🧩 GetIt (initDependencies)
│   │
│   ├── features/
│   │   ├── auth/                               # 🔐
│   │   │   ├── cubit/      (auth_cubit + auth_state)
│   │   │   ├── data/       (auth_datasource + auth_repo + user_model)
│   │   │   ├── views/      (auth_gate, welcome, start, login, signup)
│   │   │   └── widgets/    (auth_scaffold, auth_text_field, auth_button)
│   │   ├── chats/                              # 💬 قائمة المحادثات
│   │   │   ├── cubit/      (chats_cubit + chats_state)
│   │   │   ├── data/       (chat_datasource + chat_repo + chat_model)
│   │   │   ├── views/      (chats_list_view)
│   │   │   └── widgets/    (chat_tile, ai_chat_tile, unread_badge)
│   │   ├── chat_detail/                        # 📨 المحادثة المفتوحة
│   │   │   ├── cubit/      (messages_cubit + messages_state)
│   │   │   ├── data/       (message_datasource + message_repo + message_model)
│   │   │   ├── views/      (chat_view)
│   │   │   └── widgets/    (message_input_field, ai_typing_indicator)
│   │   ├── users/                              # 👥 كل المستخدمين
│   │   │   ├── cubit/      (users_cubit + users_state)
│   │   │   ├── data/       (users_datasource + users_repo)
│   │   │   └── views/      (users_list_view)
│   │   └── ai_chat/                            # 🤖
│   │       └── data/       (ai_repo — Gemini sessions per chatId)
│   │
│   └── shared/widgets/                         # ♻️
│       ├── chat_bubble.dart                    # ⭐ Bubble واحدة (sender/receiver/AI + read ticks)
│       ├── user_avatar.dart                    # Avatar + online dot
│       ├── search_text_field.dart              # شريط البحث الموحد
│       ├── empty_state.dart                    # حالة الفراغ الموحدة
│       └── app_snack_bar.dart                  # SnackBar موحد (success/error)
│
├── test/widget_test.dart                       # Unit tests (Validators + DateFormatter)
└── pubspec.yaml                                # name: chat_app ✅
```

---

## 2. 🎯 الـ Design Patterns (مع إصلاح نقاط ضعف النسخة القديمة)

| المشكلة في v1 | الحل في v2 |
|---------------|------------|
| Cubit بيعتمد على Cubit | ❌ ممنوع — كل cubit يعتمد على **Repos بس**، والـ view بتمرر الـ uid |
| `BlocProvider` جوه `build` بيتكرر | الـ provider في أعلى الـ screen مرة واحدة (أو singleton للـ AuthCubit) |
| Dead code متوثق | ✅ اتمسح كل حاجة (models مكررة، bubbles مكررة، `Message Model .dart`, `sigunp.dart`, ملف `lib/test` بتاع music player!) |
| تسمية مش موحدة | كل المجلدات والملفات `snake_case` |
| `print()` في errors | `sealed class Failure` مع رسائل عربية mapped من error codes |
| Collection names متناثرة | `FirestorePaths` في مكان واحد |
| `FirebaseAuth.instance` جوه الـ UI | الـ UI بتقرأ من `AuthCubit` بس — مفيش Firebase imports في أي view |
| Map arguments في الـ routes | `ChatViewArgs` typed + `AppRouter.onGenerateRoute` |

### الـ Cubits والـ States:

| Feature | Cubit | States | Stream? |
|---------|-------|--------|---------|
| Auth | `AuthCubit` (singleton) | `AuthInitial`, `AuthLoading`, `AuthAuthenticated(user)`, `AuthUnauthenticated`, `AuthError`, `AuthPasswordResetSent` | ✅ `authStateChanges` |
| Chats | `ChatsCubit` (factory) | `ChatsInitial`, `ChatsLoading`, `ChatsLoaded(chats, usersById, searchQuery)`, `ChatsError` | ✅ streamين مدمجين (chats + users) |
| Messages | `MessagesCubit` (factory) | `MessagesInitial`, `MessagesLoading`, `MessagesLoaded(messages, isAiTyping, isSending, actionError)`, `MessagesError` | ✅ messages stream |
| Users | `UsersCubit` (factory) | `UsersInitial`, `UsersLoading`, `UsersLoaded(users, searchQuery, isCreatingChat)`, `UsersChatReady` (navigation event), `UsersError` | ✅ users stream |

### تدفق البيانات:

```
View → context.read<XCubit>().method()
     → Cubit → Repo → DataSource → Firebase
     ← DataSource يرمي FirebaseException
     ← Repo يحولها لـ Failure (رسالة عربية)
     ← Cubit يمسك Failure → emit(Error)
     ← View: BlocListener → AppSnackBar.error()
```

---

## 3. ⚡ المميزات الجديدة (مش موجودة في النسخة القديمة)

| الميزة | إزاي اتعملت |
|--------|-------------|
| **AuthGate** | الـ home بيتبدل تلقائياً (Welcome ↔ Chats) حسب الـ auth stream — مفيش navigation يدوي بعد login/logout |
| **Unread badges شغالة فعلياً** | `FieldValue.increment(1)` في نفس الـ batch بتاع الإرسال + reset في نفس الـ batch بتاع markAsRead |
| **Read receipts** | ✓ / ✓✓ أزرق في الـ bubble (الـ field كان موجود ومش متعرض) |
| **Online / Last seen** | `PresenceService` (lifecycle) + `watchUser` stream في الـ AppBar |
| **حذف رسالة** | Long-press على رسالتك → dialog تأكيد |
| **حذف محادثة** | Long-press على الـ tile → batch delete (رسائل + document) |
| **نسيت كلمة المرور** | `sendPasswordResetEmail` — كان TODO في v1 |
| **AI typing indicator** | 3 نقاط متحركة + الـ AI بقى sender حقيقي (`ai_agent`) بدل trick الـ type |
| **AI unread badge** | الـ AI بيبعت كـ sender منفصل → الـ badge بيشتغل عليه |
| **Search موحد** | `SearchTextField` واحد + الـ filtering جوه الـ states (مش جوه الـ build) |
| **Empty states** | `EmptyState` widget موحد |
| **Unit tests** | 8 اختبارات (Validators + DateFormatter) |
| **تحسين أداء** | `reverse: true` ListView (مفيش reverse يدوي للقائمة)، `listenWhen`/`buildWhen` لتقليل rebuilds |

### قرارات مدروسة:
- **مفيش `searchUserByEmail`** — كانت موجودة ومش مستخدمة (dead code)
- **اتشال `modal_progress_hud_nsn` و `flutter_chat_bubble`** — الـ cubit states والـ bubble الـ custom بيغنوا عنهم
- **AI senderId = `ai_agent`** — الـ Firestore rules بتسمح بكده، فمفيش داعي للـ workaround

---

## 4. 📦 الـ Packages

| الـ Package | الاستخدام |
|-------------|-----------|
| `flutter_bloc` | State Management |
| `get_it` | Dependency Injection |
| `equatable` | مقارنة الـ States/Models |
| `firebase_core` / `firebase_auth` / `cloud_firestore` | Backend |
| `firebase_ai` | Gemini AI assistant |
| `flutter_svg` | أيقونات الـ auth screens |
| `cupertino_icons` | أيقونات |

---

## 5. 📋 قابلية النقل (Portable)

| القطعة | Portable? |
|--------|:---------:|
| `core/` كامل (failure, validators, paths, theme, router, di) | ✅ |
| أي feature مجلد مستقل | ✅ |
| `shared/widgets/` | ✅ |
| `PresenceService` | ✅ لأي مشروع Firebase |
| نمط **Streams + Cubit** (cancel في close) | ✅ لأي realtime feature |

> **القاعدة الجديدة المستفادة:** لو الـ feature realtime، الـ cubit يمتلك الـ `StreamSubscription`، يعمل `cancel()` القديم قبل كل subscription جديد، و`cancel()` في `close()`.
