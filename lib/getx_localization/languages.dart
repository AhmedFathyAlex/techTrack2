
import 'package:get/get_navigation/src/root/internacionalization.dart';

class languages extends  Translations{


  Map<String ,Map<String,String>> get keys => {
    'en_US':{
       /// login screen
      'Username':'Username',
      'Password':'Password',
      //map screen
      'RUNNING':'RUNNING',
      'STOPED':'STOPED',
      'IDLE':'IDLE',
      'INACTIVE':'INACTIVE',
      'EXPIRED':'EXPIRED',

      //bottom naviigation bar
      'List':'List',
      'Map':'Map',
      'Dashboard':'Dashboard',
      'Events':'Events',
      'Menu':'Menu',

      //list screen
      'All Vehicles':'All Vehicles',
      'Running':'Running',
      'Stopped':'Stopped',
      'Idle':'Idle',
      'InActive':'In Active',
      'Expired':'Expired',
      'NotConnected':'Not Connected',
      'LastPacket':'Update',
      'TotalMI':'Total km',
      'EngineHours':'EngineHours',
      'Speed':'Speed',
      'Since':'Since',
      //list dialog
      'LiveMap':'Live Map',
      'Mileage':'Mileage',
      'Playback':'Playback',
      'Reports':'Reports',
      'Lock':'Lock',
      'VehicleInfo':'Vehicle Info',
      'Trips':'Trips',
      'Share':'Share',
      'NearBy':'NearBy',
      //live screen
      'ViewAddress':'ViewAddress',
      'Odometer':'Odometer',
      'Tracking':'Tracking',
      'Dashboard':'Dashboard',
      'Playback':'Playback',
      'Lock':'Lock',
      'VehicleSetting':'Vehicle Setting',
      'Analytics':'Analytics',
      'Alerts':'Alerts',
      //dashboard
      'TodayAlerts':'Today Alerts',
      'Geofence':'Geofence',
      'Overspeed':'Overspeed',
      'ExcessIdle':'Excess Idle',
      'Parked':'Parked',
      'IgnitionOn':'Ignition On',
      'IgnitionOff':'Ignition Off',
      //playback & km detail
      'Yesterday':'Yesterday',
      'Last7Days':'Last 7 Days',
      'ViewMIDetial':'View MI Detial',
      'ViewPlaybackHistory':'View Playback History',

      //settign screen
      'More':'More',
      'PayNow':'Pay Now',
      'Support':'Support',
      'Alerts':'Alerts',
      'GeofenceSetting':'Geofence Setting',
      'Overspeeding':'Overspeeding',
      'ChangeLanguage':'Change Language',
      'ChangeDeviceSetting':'Change Device Setting',
      'RegisterANewDevice':'Register A New Device',
      'ChangeLanguage':'Change Language',

      'NotificationSetting':'Notification Setting',

      'ChangePassword':'Change Password',
      'SignOut':'Sign Out',

    },
// french
    'fr_CA':{

      /// login screen
      'Username':"Nom d'utilisateur",
      'Password':'Mot de passe',
      //map screen
      'RUNNING':"EN COURS D'EXÉCUTION",
      'STOPED':'ARRÊTÉ',
      'IDLE':'RALENTI',
      'INACTIVE':'INACTIF',
      'EXPIRED':'EXPIRÉ',

      //bottom naviigation bar
      'List':'Liste',
      'Map':'Map',
      'Dashboard':'Dashboard',
      'Events':' Événements',
      'Menu':'Menu',

      //list screen
      'All Vehicles':' Tous les véhicules',
      'Running':"En cours d'exécution",
      'Stopped':'Arrêté ',
      'Idle':'Au repos',
      'InActive':'En actif',
      'Expired':'Expiré',
      'NotConnected':'Non connecté',
      'LastPacket':'Dernier paquet',
      'TotalMI':'Total km',
      'EngineHours':'Heures Moteur',
      'Speed':'Vitesse',
      'Since':'Depuis',
      //list dialog
      'LiveMap':'Carte en direct',
      'Mileage':'Kilométrage',
      'Playback':'Lecture',
      'Reports':'Rapports',
      'Lock':'Verrouillage',
      'VehicleInfo':'Info véhicule',
      'Trips':'Voyages',
      'Share':'partage',
      'NearBy':'À proximité',
      //live screen
      'ViewAddress':'Voir Address',
      'Odometer':'Odometer',
      'Tracking':'Suivi',
      'Dashboard':'Dashboard',
      'Playback':'Lecture',
      'Lock':'Verrouillage',
      'VehicleSetting':'Réglage du véhicule',
      'Analytics':'Analyses',
      'Alerts':'Alertes',
      //dashboard
      'TodayAlerts':'Alertes d\'aujourd\'hui',
      'Geofence':'Géoclôture',
      'Overspeed':'Survitesse',
      'ExcessIdle':'Ralenti excessif',
      'Parked':'Garé',
      'IgnitionOn':'Allumage activé',
      'IgnitionOff':'Allumage désactivé',
      //playback & km detail
      'Yesterday':'Hier',
      'Last7Days':'7 derniers jours ',
      'ViewMIDetial':'Afficher les détails km',
      'ViewPlaybackHistory':'Afficher l\'historique de lecture',

      //settign screen
      'More':'plus',
      'PayNow':'Payer maintenant',
      'Support':'Support',
      'Alerts':'Alertes',
      'GeofenceSetting':'Paramètres de clôture géographique',
      'Overspeeding':'Excès de vitesse',
      'ChangeLanguage':'Changer la langue',
      'ChangeDeviceSetting':'Modifier les paramètres de l\'appareil',
      'RegisterANewDevice':'Enregistrer un nouvel appareil',
      'ChangeLanguage':'Changer la langue',

      'NotificationSetting':'Paramètre de notification',

      'ChangePassword':'Changer le mot de passe',
      'SignOut':'Déconnexion',
      // /// login screen
      // 'Username':'Nom d\'utilisateur',
      // 'Password':'Mot de passe',
      // //map screen
      // 'RUNNING':'mouvement',
      // 'STOPED':'ARRÊTÉ',
      // 'IDLE':'inactif',
      // 'INACTIVE':'INACTIVE',
      // 'EXPIRED':'expiré',
      //
      // //bottom naviigation bar
      // 'List':'liste',
      // 'Map':'Carte',
      // 'Dashboard':'Tiret',
      // 'Events':'Événement',
      // 'Menu':'Menu',
      //
      // //list screen
      // 'AllVehicle':'Tout',
      // 'Running':'mouvement',
      // 'Stopped':'ARRÊTÉ',
      // 'Idle':'Inactif',
      // 'InActive':'In Active',
      // 'Expired':'Expiré',
      // 'NotConnected':'Not Connected',
      // 'LastPacket':'Dernier paquet',
      // 'TotalMI':'Total MI',
      // 'EngineHour':'Heure moteur',
      // 'Speed':'Vitesse',
      // 'Since':'Depuis',
      // //list dialog
      // 'LiveMap':'Carte en direct',
      // 'Mileage':'Kilométrage',
      // 'Playback':'Relecture',
      // 'Reports':'Rapports',
      // 'Lock':'Verrouillage',
      // 'VehicleInfo':'Info sur le véhicule',
      // 'Trips':'Voyages',
      // 'Share':'Partager',
      // 'NearBy':'Proche',
      //
      //
      // //live screen
      // 'ViewAddress':'ViewAddress',
      // 'Odometer':'Odometer',
      // 'Tracking':'Tracking',
      // 'Dashboard':'Dashboard',
      // 'Playback':'Playback',
      // 'Lock':'Lock',
      // 'VehicleSetting':'Vehicle Setting',
      // 'Analytics':'Analytics',
      // 'Alerts':'Alerts',
      // //dashboard
      // 'Alerts':'Alertes',
      // 'TodayAlerts':'Alertes du jour',
      // 'Geofence':'Géoclôture',
      // 'Overspeed':'Survitesse',
      // 'ExcessIdle':'Excès de ralenti',
      // 'Parked':'Garé',
      // 'IgnitionOn':'Contact établi',
      // 'IgnitionOff':'Allumage éteint',
      //
      // //playback & km detail
      // 'Yesterday':'hier',
      // 'Last7Days':'Les 7 derniers jours',
      // 'ViewMIDetial':'Voir les détails de MI',
      // 'ViewPlaybackHistory':'Afficher l\'historique de lecture',
      //
      //
      // //settign screen
      // 'More':'Plus',
      // 'PayNow':'Payez',
      // 'Support':'Soutien',
      // 'Alerts':'Alertes',
      // 'GeofenceSetting':'Géoclôture Paramètre',
      // 'Overspeeding':'Excès de vitesse',
      // 'ChangeLanguage':'Changer de langue',
      // 'ChangeDeviceSetting':'Changement Appareil Paramètre',
      // 'RegisterANewDevice':'Enregistrez un nouvel appareil',
      // 'ChangeLanguage':'Changer de langue',
      //
      // 'NotificationSetting':'Notification Paramètre',
      //
      // 'ChangePassword':'Changer Mot de passe',
      // 'SignOut':'Se déconnecter',
    },

    // saudi arbia arabic
    'ar_SA':{
      // login screen
      'Username':'اسم المستخدم',
      'Email':'بريد إلكتروني',
      'Password':'كلمة المرور',
      // Home Screen
      'AllVehicle':'كل المركبات',
      'Running':'تتحرك',
      'Stopped':'متوقفة',
      'Idle':'خاملة',
      'InActive':'غير نشطة',
      'Expired':'منتهية الصلاحية',
      'Alerts(Today)' : 'التنبيهات (اليوم) ',
      "IgnitionOff" : 'ايقاف المحرك ',
//map screen
      'RUNNING':'تشغيل',
      'New Password':'كلمة المرور الجديدة',
      'Retype Password':'أعد إدخال كلمة السر',
      'STOPPED':'توقف',
      'Cancel':'يلغي',
      'OK':'نعم',
      'Settings':'إعدادات',
      'IDLE':'متوقفه والمحرك يعمل',
      'INACTIVE':'غير نشط',
      'EXPIRED':'منتهي الصلاحية',

//bottom navigation bar
      'List':'قائمة المركبات',
      'Map':'الخريطة',
      'Dashboard':'اللوحة الرئيسية',
      'Events':'الاشعارات ',
      'Menu':'القائمة',
      'Home':'بيت',
      'Hospital':'مستشفى',
      'ATM':'ماكينة الصراف \nالآلي',
      'Mosque':'مسجد',
      'Restaurant':'مطعم',
      'Gas Station':'محطة غاز',
      'Petrol Pump':'مضخة البنزين',
      'Hotel':'الفندق',
      'Shopping Mall':'مركز تسوق',
      'Police Station':'قسم الامن',
      'Service Point':'نقطة خدمة',
      'Train Station':'محطة القطار',
      'Bus Stop':'موقف باص',
      'Quick Links':'روابط سريعة',
      'Near By Places':'الاماكن المجاورة',
      'Banner':'راية',
      'Vehicle Status':'حالة المركبة',
      'No Data':'لايوجد بيانات',
      'Alerts(Today)':'التنبيهات (اليوم)',
      'History':'تاريخ',
      'Enter device name or IMEI':'أدخل اسم الجهاز أو IMEI',



//list screen
      'All':'الجميع',
      'Route Start':'بداية الطريق',
      'Route End':'نهاية الطريق',
      'Route Length':'طول الطريق',
      'Top Speed':'السرعة القصوى',
      'Move Time':'تحرك الوقت',
      'Stop Time':'توقف الوقت',
      'Total Weight':'الوزن الكلي',
      'Not Found':'غير معثور عليه',
      'Filter':'منقي',
      'Today':'اليوم',
      'Yesterday':'أمس',
      'Last 7 Days':'اخر 7 ايام',
      'View Detail':'عرض التفاصيل',
      'Total KM':'إجمالي كم',
      'Engine Hour':'ساعة المحرك',
      'Expiration Date':'تاريخ انتهاء الصلاحية',
      'Stop':'قف',
      'Running':'متحركه',
      'Stopped':'متوقفه',
      'Idle':'انتظار',
      'InActive':'غير نشط',
      'Expired':'منتهي الصلاحية',
      'NotConnected':'غير متصل',
      'Not connected':'غير متصل',
      'LastPacket':'آخر اشاره',
      'TotalMI':'إجمالي الاميال',
      'EngineHours':'ساعات المحرك',
      'Speed':'السرعة',
      'Since':'منذ',
//list dialog
      'LiveMap':'خريطة مباشرة',
      'Mileage':'المسافة',
      'Playback':'السجل المسبق',
      'Reports':'التقارير',
      'Lock':'قفل',
      'VehicleInfo':'معلومات المركبة',
      'Trips':'الرحلات',
      'Share':'مشاركة',
      'NearBy':'القريب',

//live screen
      'ViewAddress':'عرض العنوان',
      'Odometer':'عداد المسافات',
      'Tracking':'تتبع',
      'Dashboard':'لوحة القيادة',
      'Playback':'السجل المسبق',
      'Lock':'قفل',
      'VehicleSetting':'إعدادات المركبة',
      'Analytics':'التحليلات',
      'Alerts':'التنبيهات',

//dashboard
      'TodayAlerts':'تنبيهات اليوم',
      'Geofence':'المعالم الجغرافية ',
      'Overspeed':'تجاوز السرعة',
      'ExcessIdle':'خمول زائد',
      'Parked':'متوقف',
      'Ignition On':'تشغيل السويتش',
      'Ignition Off':'إيقاف السويتش',

//playback & km detail
      'Yesterday':'الأمس',
      'Last7Days':'آخر 7 أيام',
      'ViewMIDetial':'عرض تفاصيل الميل',
      'ViewPlaybackHistory':'عرض سجل التتبع المسبق',

//setting screen
      'More':'المزيد',
      'Setting':'الاعدادات',
      'PayNow':'ادفع الآن',
      'Support':'الدعم',
      'Alerts':'التنبيهات',
      'GeofenceSetting':'إعدادات الجيوسياج',
      'Overspeeding':'تجاوز السرعة',
      'ChangeLanguage':'تغيير اللغة',
      'ChangeDeviceSetting':'تغيير إعدادات الجهاز',
      'RegisterANewDevice':'تسجيل جهاز جديد',
      'ChangeLanguage':'تغيير اللغة',
      'Terms&Conditions':'الشروط والأحكام',

      'NotificationSetting':'إعدادات الإشعارات',

      'ChangePassword':'تغيير كلمة المرور',
      'SignOut':'تسجيل الخروج',
      'Send Command':'إرسال الأمر',
      'Change Password':'تغيير كلمة المرور',


    },
  // moroco arabic
    'ar_EG':{
      //list screen
      'All':'الكل',
      'Moving':'يتحرك',
      'Idle':'الخمول',
      'Parked':'متوقفة',
      'Offline':'غير متصل',
      'Expired':'انتهت صلاحيتها',
      'NotConnected':'غير متصل',
      'Ignition':'اشتعال',
      'GPS':'GPS',
      'Network Status':'حالة الشبكة',
      'TodayDistance':'مسافة اليوم',
      'ExpiresOn':'انتهاء الصلاحية في',

      //live screen
      'Speed':'السرعة',
      'Odometer':'عداد المسافات',
      'Tracking':'التتبع',
      'Dash':'لوحة المعلومات',
      'Playback':'تشغيل',
      'Settings Screen':'شاشة إعدادات',
      'Lock':'قفل',
      'VehicleSetting':'إعدادات المركبة',
      'Analytics':'تحليلات',
      'Alerts':'التنبيهات',


      //settign screen
      'More':'اكثر',
      'PayNow':'الدفع الآن',
      'Reports':'تقارير',
      'Maintenance':'صيانة',
      'ImageGallery':'معرض الصور',
      'Notification':'الإخطار',

      'Address':'عنوان',
      'ChangeLanguage':'تغيير اللغة',
      'Expense':'النفقة',
      'GeofenceSetting':'إعداد السياج الجغرافي',
      'NotificationSetting':'إعداد الإشعارات',
      'ChangePassword':'تغيير كلمة المرور',
      'Logout':'تسجيل الخروج',



/*      //list screen
      'All':'All',
      'Moving':'Moving',
      'Idle':'Idle',
      'Parked':'Parked',
      'Offline':'Offline',
      'Expired':'Expired',
      'NotConnected':'Not Connected',
      'Ignition':'Ignition',
      'GPS':'GPS',
      'Network Status':'Network Status',
      'TodayDistance':'Today Distance',
      'ExpiresOn':'Expires On',
      //live screen
      'Speed':'Speed',
      'Odometer':'Odometer',
      'Tracking':'Tracking',
      'Dashboard':'Dashboard',
      'Playback':'Playback',
      'Lock':'Lock',
      'VehicleSetting':'Vehicle Setting',
      'Analytics':'Analytics',
      'Alerts':'Alerts',
      //settign screen
      'More':'More',
      'PayNow':'Pay Now',
      'Reports':'Reports',
      'Maintenance':'Maintenance',
      'ImageGallery':'Image Gallery',
      'Notification':'Notification',
      'Address':'Address',
      'Expense':'Expense',
      'GeofenceSetting':'Geofence Setting',
      'NotificationSetting':'Notification Setting',
      'ChangePassword':'Change Password',
      'Logout':'Logout',*/

    },
    'ur_PK':{
      // login screen
      'Username':'صارف کا نام',
      'Password':'پاس ورڈ',
//map screen
      'RUNNING':'چل رہا ہے',
      'STOPED':'روک دیا گیا',
      'IDLE':'فارغ',
      'INACTIVE':'غیر فعال',
      'EXPIRED':'میعاد ختم',

//bottom navigation bar
      'List':'فہرست',
      'Map':'نقشہ',
      'Dashboard':'ڈیش بورڈ',
      'Events':'واقعات',
      'Menu':'مینو',

//list screen
      'All Vehicles':'تمام گاڑیاں',
      'Running':'چل رہا ہے',
      'Stopped':'روک دیا گیا',
      'Idle':'فارغ',
      'InActive':'غیر فعال',
      'Expired':'میعاد ختم',
      'NotConnected':'مربوط نہیں',
      'LastPacket':'آخری پیکٹ',
      'TotalMI':'کل میل',
      'EngineHours':'انجن کے گھنٹے',
      'Speed':'رفتار',
      'Since':'سے',
//list dialog
      'LiveMap':'لائیو نقشہ',
      'Mileage':'میلیج',
      'Playback':'پلے بیک',
      'Reports':'رپورٹس',
      'Lock':'تالا',
      'VehicleInfo':'گاڑی کی معلومات',
      'Trips':'سفر',
      'Share':'شیئر کریں',
      'NearBy':'قریبی',

//live screen
      'ViewAddress':'پتہ دیکھیں',
      'Odometer':'اوڈومیٹر',
      'Tracking':'ٹریکنگ',
      'Dashboard':'ڈیش بورڈ',
      'Playback':'پلے بیک',
      'Lock':'تالا',
      'VehicleSetting':'گاڑی کی ترتیبات',
      'Analytics':'تجزیات',
      'Alerts':'الرٹس',

//dashboard
      'TodayAlerts':'آج کے الرٹس',
      'Geofence':'جیوفینس',
      'Overspeed':'تیز رفتاری',
      'ExcessIdle':'زیادہ فارغ',
      'Parked':'پارک کیا گیا',
      'IgnitionOn':'اگنیشن آن',
      'IgnitionOff':'اگنیشن آف',

//playback & km detail
      'Yesterday':'گزشتہ روز',
      'Last7Days':'پچھلے 7 دن',
      'ViewMIDetial':'میل کی تفصیل دیکھیں',
      'ViewPlaybackHistory':'پلے بیک کی تاریخ دیکھیں',

//setting screen
      'More':'مزید',
      'PayNow':'ابھی ادا کریں',
      'Support':'سپورٹ',
      'Alerts':'الرٹس',
      'GeofenceSetting':'جیوفینس کی ترتیبات',
      'Overspeeding':'تیز رفتاری',
      'ChangeLanguage':'زبان تبدیل کریں',
      'ChangeDeviceSetting':'ڈیوائس کی ترتیبات تبدیل کریں',
      'RegisterANewDevice':'نئی ڈیوائس رجسٹر کریں',
      'ChangeLanguage':'زبان تبدیل کریں',

      'NotificationSetting':'اطلاعات کی ترتیبات',

      'ChangePassword':'پاس ورڈ تبدیل کریں',
      'SignOut':'سائن آؤٹ',
    }  ,


    'bn_BD':{
      'email_hint':'Email UR'
    }  ,


    'spa_SV':{
      'RUNNING':'CORRIENDO',
      'STOPED':'DETENIDO',
      'IDLE':'RALENTY',
      'INACTIVE':'INACTIVO',
      'EXPIRED':'EXPIRADO'
    },

    // Germany
    'de_DE':{
      /// login screen : Anmeldebildschirm
      'Username':'Benutzername',
      'Password':'Passwort',
      //map screen : Kartenansicht
      'RUNNING':'Fahrende',
      'STOPED':'Stehende',
      'IDLE':'Leerlauf',
      'INACTIVE':'Kein Signal',
      'EXPIRED':'Abo Abgelaufen',

      //bottom naviigation bar :Untere Navigationsleiste
      'List':'Fahrezeuge',
      'Map':'Karte',
      'Dashboard':'Berichte',
      'Events':'Alarme',
      'Menu':'Menu',

      //list screen: Listenbildschirm
      'All Vehicles':'Alle',
      'Running':'Fahrende',
      'Stopped':'Stehende',
      'Idle':'Leerlauf',
      'InActive':'Kein Signal',
      'Expired':'Abo Abgelaufen',
      'NotConnected':'Nicht verbunden',
      'LastPacket':'Letzte Verbindung',
      'TotalMI':'Tägl.Kilometerstand ',
      'EngineHours':'Zündungszeit',
      'Speed':'Geschwindigkeit',
      'Since':'Seit',
      //list dialog :Infoboard
      'LiveMap':'Live Orten',
      'Mileage':'Reise info',
      'Playback':'Reise Bericht',
      'Reports':'Fahrtenbuch',
      'Lock':'Fahrzeug Stoppen',
      'VehicleInfo':'Fahrzeug-info',
      'Trips':'Reisen',
      'Share':'Standort Senden',
      'NearBy':'Reisebedarf',
      //live screen: Live-Bildschirm
      'ViewAddress':'Adresse anzeigen',
      'Odometer':'Gesamtkilometer',
      'Tracking':'Verfolgung',
      'Dashboard':'Mehr',
      'Playback':'Wiedergabe',
      'Lock':'Sperren',
      'VehicleSetting':'Fahrzeugeinstellung',
      'Analytics':'Analytics',
      'Alerts':'Alarme',
      //dashboard: Gesamt Berichte
      'TodayAlerts':'Tägliche Benachrichtigungen',
      'Geofence':'Definierte Zone',
      'Overspeed':'Übergeschwindigkeit',
      'ExcessIdle':'Übermäßiger Leerlauf',
      'Parked':'Geparkt',
      'IgnitionOn':'Zündung an',
      'IgnitionOff':'Zündung aus',
      //Playback & Km Detail: Reise Bericht und Km-Details
      'Yesterday':'Gestern',
      'Last7Days':'Letzten 7 Tage',
      'ViewMIDetial':'Km-Details anzeigen',
      'ViewPlaybackHistory':'Reise Details',

      //Setting screen: Einstellungs Bildschirm
      'More':'Mehr',
      'PayNow':'Zahlen Sie jetzt',
      'Support':'Support',
      'Alerts':'Alarme / Warnungen',
      'GeofenceSetting':'Definierte Zone Einstellung',
      'Overspeeding':'Übergeschwindigkeit',
      'ChangeLanguage':'Sprache ändern',
      'ChangeDeviceSetting':'Geräteeinstellung ändern',
      'RegisterANewDevice':'Geräte Hinzufügen',
      'ChangeLanguage':'Sprache ändern',

      'NotificationSetting':'Benachrichtigung Ein / Aus',

      'ChangePassword':'Kennwort ändern',
      'SignOut':'Abmelden',
      'Send Command':'Send Command',

    },
    //turkish
    'tr_TR':{
      /// login screen : Giriş ekranı
      'Username':'Kullanıcı adı',
      'Password':'Şifre',
      //map screen : Harita Görünümü
      'RUNNING':'Hareketli',
      'STOPED':'Duran',
      'IDLE':'Rölanti',
      'INACTIVE':'Sinyal Yok',
      'EXPIRED':'Abonelik Yok',

      //bottom naviigation bar : Alt Kategoriler
      'List':'Araçlarım',
      'Map':'Harita',
      'Dashboard':'Rapor Yönetimi',
      'Events':'Bildirimler',
      'Menu':'Menü',

      //list screen: Liste ekranı
      'All Vehicles':'Tümü',
      'Running':'Hareketli',
      'Stopped':'Duran',
      'Idle':'Rölanti',
      'InActive':'Sinyal Yok',
      'Expired':'Abonelik Yok',
      'NotConnected':'Bağlı değil',
      'LastPacket':'Son Bağlantı',
      'TotalMI':'Günlük Km ',
      'EngineHours':'Kontak Süresi',
      'Speed':'Hiz',
      'Since':'Son Bilgi',
      //list dialog :Bilgi panosu
      'LiveMap':'Canli izle',
      'Mileage':'Seyahat Bilgileri',
      'Playback':'Seyahat Özet Raporu',
      'Reports':'Aktivite Raporu',
      'Lock':'Araci Bloke et!',
      'VehicleInfo':'Araç Bilgisi',
      'Trips':'Seyahat',
      'Share':'Konum Gönder',
      'NearBy':'Seyahat Yardimi',
      //live screen: Ana ekran
      'ViewAddress':'Adresi Göster',
      'Odometer':'Km Göstergesi',
      'Tracking':'İzlemek',
      'Dashboard':'Menü',
      'Playback':'Seyahat Özet Raporu',
      'Lock':'Bloke Et',
      'VehicleSetting':'Arac Yönetimi',
      'Analytics':'Analiz',
      'Alerts':'Bildirimler',
      //dashboard: Toplam Raporlar
      'TodayAlerts':'Günlük Bildirimler',
      'Geofence':'Tanımlanmış Bölge',
      'Overspeed':'Aşırı Hız',
      'ExcessIdle':'Aşırı Rölanti',
      'Parked':'Park Halinde',
      'IgnitionOn':'Kontak Acik',
      'IgnitionOff':'Kontak Kapali',
      //Playback & Km Detail: Seyahat Raporu ve Km Ayrıntıları
      'Yesterday':'Dün',
      'Last7Days':' Son 7 Gün',
      'ViewMIDetial':'Km Detaylari Görüntüle',
      'ViewPlaybackHistory':'Seyahat Detaylari',

      //Setting screen: Ayarlar Ekranı
      'More':'Daha Fazla',
      'PayNow':'Fatura Öde €',
      'Support':'Müşteri Hizmetleri',
      'Alerts':'Bildirimler',
      'GeofenceSetting':'Özel Bölge ayarı',
      'Overspeeding':'Aşırı hız Bildirimleri',
      'ChangeLanguage':'Dili Değiştir',
      'ChangeDeviceSetting':'Cihaz Ayarlarini Değiştir ',
      'RegisterANewDevice':'Cihaz Ekle',
      'ChangeLanguage':'Dil seçimi',

      'NotificationSetting':'Bildirimleri Aç /Kapat',

      'ChangePassword':'Şifre Değiştir',
      'SignOut':'Çıkış Yap',
    },
  //pt-BR	Portuguese (Brazil)
  'pt_BR':{
  /// login screen
  'Username':'Nome de usuário',
  'Password':'Senha',
  //map screen
  'RUNNING':'CORRENDO',
  'STOPED':'PARADO',
  'IDLE':'DORMINDO',
  'INACTIVE':'INATIVO',
  'EXPIRED':'EXPIRADO',

  //bottom naviigation bar
  'List':'Lista',
  'Map':'Mapa',
  'Dashboard':'Painel',
  'Events':'Eventos',
  'Menu':'Menu',

  //list screen
  'All Vehicles':'Todos Veículos',
  'Running':'Correndo',
  'Stopped':'Parado',
  'Idle':'Inativo',
  'InActive':'Ativo',
  'Expired':'Expirado',
  'NotConnected':'Não Connectado',
  'LastPacket':'Ultimo Pacote',
  'TotalMI':'MeuTotal',
  'EngineHours':'Motor Horas',
  'Speed':'velocidade',
  'Since':'Desde',
  //list dialog
  'LiveMap':'Mapa ao vivo',
  'Mileage':'Quilometragem',
  'Playback':'Reprodução',
  'Reports':'Relatorio',
  'Lock':'Bloquear',
  'VehicleInfo':'Veiculo informação',
  'Trips':'Viagens',
  'Share':'Compatilhe',
  'NearBy':'Perto',
  //live screen
  'ViewAddress':'Ver Endereço',
  'Odometer':'Odometro',
  'Tracking':'Rastreamento',
  'Dashboard':'Painel',
  'Playback':'Reprodução',
  'Lock':'Bloquear',
  'VehicleSetting':'Configuração do veículo',
  'Analytics':'Analítica',
  'Alerts':'Alertas',
  //dashboard
  'TodayAlerts':'Today Alertas',
  'Geofence':'Cerca geográfica',
  'Overspeed':'Overspeed',
  'ExcessIdle':'Excesso de inatividade',
  'Parked':'Estacionado',
  'IgnitionOn':'Ignição ligada',
  'IgnitionOff':'Ignição Desligada',
  //playback & km detail
  'Yesterday':'Ontem',
  'Last7Days':'Últimos 7 Dias',
  'ViewMIDetial':'Ver MI Detial',
  'ViewPlaybackHistory':'Ver histórico de reprodução',

  //settign screen
  'More':'Mais',
  'PayNow':'Pay Now',
  'Support':'Suporte',
  'Alerts':'Alertas',
  'GeofenceSetting':'Configuração de cerca geográfica',
  'Overspeeding':'Overspeeding',
  'ChangeLanguage':'Excesso de velocidade',
  'ChangeDeviceSetting':'Alterar configuração do dispositivo',
  'RegisterANewDevice':'Registrar um novo dispositivo',
  'ChangeLanguage':'Alterar pais',

  'NotificationSetting':'Configuração de notificação',

  'ChangePassword':'Configuração de notificação',
  'SignOut':'Sair',
}
  };
}