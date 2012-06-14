Malcom Lib iOS
==============

Intro
-----

Intro about malcom-lib-ios

Integración
------------

* Clona este repositorio o descargate el zip:

        git://github.com/MyMalcom/malcom-lib-ios.git
    
* Añade una de lasa dos versiones de la librería:
    * Librería estática: Añadir la carpeta de la librería estática. Si no se quiere añadir el módulo de publicidad no es necesario añadir la carpeta ads. Hay que añadir también la librería TouchJSON que está en el directorio "External".
    * Código fuente: Se añade el código al proyecto. En el caso de que no se quiera usar alguno de los módulos (Configuración, Publicidad, Notificaciones o Estadísticas) se puede borrar su correspondiente carpeta.

* Añadir los siguientes frameworks al proyecto:

   * MediaPlayer.framework
   * AVFoundation.framework
   * CFNetwork.framework
   * SystemConfiguration.framework
   * MobileCoreServices.framework
   * QuartzCore.framework
   * CoreTelephony.framework
   * CoreLocation.framework
   * AudioToolbox.framework
   * MessageUI.framework
   * libz.1.2.5.dylib
   * iAd.framework (solo necesario si se añade el módulo de publicidad)


* Añadir en "Other C Flags", en el entorno de producción:
        
        -DDISTRIBUTION=1

* Añadir en "Other link Flags"
       
        -all_load -ObjC 

Sample App
----------


Usando la librería
------------------

Inicializar:

Para inicializar malcom en la aplicación hay que importar la librería MCMLib.h

		#import "MalcomLib.h"

y hacer uso del siguiente método:

		[MalcomLib initWithUUID:@"UUID" 
                   andSecretKey:@"SECRETKEY" 
                       withAdId:@"ADID"];
                       
Pasándole los datos que se proporcionan en la configuración de su aplicación.

Si queremos que aparezca por consola el log de Malcom hay que usar este método:

	[MalcomLib showLog:YES];

Configuración:

Llamar al siguiente método:

	[MalcomLib loadConfiguration:viewController withDelegate:delegate withLabel:NO];
	
Donde el primer parámetro será la vista donde se cargará la configuración, el segundo su delegado y el tercero si desea que aparezca o no el label con la información de descarga de la configuración.

Notificaciones:

Previamente hay que tener definido la variable -DDISTRIBUTION=1 en el entorno de producción, tal y como se indicó en el punto de la integración.
En el método didFinishLaunchingWithOptions de la clase AppDelegate hay que añadir este código:

	#if DISTRIBUTION
	    
	    [MalcomLib startNotifications:application withOptions:launchOptions isDevelopmentMode:NO];
	    
	#else
	    
	    [MalcomLib startNotifications:application withOptions:launchOptions isDevelopmentMode:YES];
	    
	#endif
	
Y en el AppDelegate se añaden los siguientes métodos:

	- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	    
	    [MalcomLib didRegisterForRemoteNotificationsWithDeviceToken:devToken];
	    
	}
	
	- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
	    
	    [MalcomLib didFailToRegisterForRemoteNotificationsWithError:err];
	    
	}
	
	- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	    
	    [MalcomLib didReceiveRemoteNotification:userInfo active:NO];
	    
	}

Estadísticas:

Para el uso de estadísticas, en primer lugar hay que inicializarlas en los métodos didFinishLaunchingWithOption, applicationWillEnterForeground y applicationDidBecomeActive de la clase AppDelegate de la siguiente forma:

	[MalcomLib initAndStartBeacon:YES useOnlyWiFi:YES];
	
Donde el primer parámetro es si queremos utilizar geolocalización (solo usar si la aplicación ya lo necesitaba) y el segundo para enviar las estadísticas solo con conexión wifi.

Una vez hecho esto tenemos el siguiente método:

	[MalcomLib endBeacon];
	
el cual se usará cuando salgamos de la aplicación, es decir, en los métodos applicationDidEnterBackground y applicationWillTerminate.

Y para obtener estadística de diferentes acciones, vistas, etc. tenemos:

Para comenzar a registrar la estadística:

	[MalcomLib startBeaconWithName:@"ViewController"];
	

Para terminar y enviar la estadística:
	
	[MalcomLib endBeaconWithName:@"ViewController"];
	

Publicidad:

Para añadir la publicidad a una vista usaremos el siguiente método:

	[MalcomAd presentAd:viewController atPosition:point];
	
Donde viewController es la vista donde la queremos mostrar (si es en la vista donde nos encontramos usaremos 'self', y point la posición.

Si queremos indicar el tamaño de la publicidad, podemos usar el siguiente método:

	[MalcomAd presentAd:viewController atPosition:point withSize:size];

Change log
----------

v1.3.3

Se muestra un error cuando se compile para release o distribution y no esté la variable DISTRIBUTION a 1. De esta forma se intenta evitar enviar a la App Store aplicaciones que registren en SANDBOX. Se soluciona también un problema que había con la SPLASH en iOS 5.0 o superiores 
    
    * MCMCore
    	* Se muestra un error cuando se compile para release o distribution y no esté la variable DISTRIBUTION a 1.
    
    * MCMConfig
    	* Bug: Se soluciona también un problema que había con la SPLASH en iOS 5.0 o superiores.

v1.3.2

Corrección de un bug en el control de las versiones del módulo de configuración y creación de un método en el módulo de la publicidad para poder cambiar la posición del banner

	* MCMAd
	    * Posición del banner: Creación de un método para poder cambiar la posición del banner.

	* MCMConfig
	    * Bug: Corregido el problema con el control de las versiones del módulo de configuración



v1.3.1

Modificación de la configuración y otros bugs menores

	* MCMConfig
	
	  * Se modifica la forma de obtener los datos de configuración para mostrar las diferentes alertas.
	  * Se podrá mostrar a la vez tanto la alerta como un intersitial (web). 


v1.3.0

Modificación de librerías y otros bugs menores

	* MCMAd
	    *Other: Eliminada Admob para reducir peso de la librería

	* MCMNotifications
	    * Bug: Corregido el problema con la lectura y borrado del badge de las notificaciones

	* Externas
	    * Feature: Modificados los nombres de las clases y constantes para evitar error de duplicidad durante el compilado


v1.2.1

Actualización para SDK5

	* MCAddons
	    * Other: Actualización para SDK5

	* MCMAd
	    * Bug: Crash cuando se incluía este módulo sin AdWhirlId configurado

	* MCMCore
	    * Other: Actualización para SDK5

	* MCMConfig
	    * Other: Actualización para SDK5


v1.2.0

Actualización de APIs, inclusión de seguridad y otras mejoras menores

	* MCMCore
	    * Feature: Incluido nuevo request para comunicaciones seguras mediante HMAC
	    * Optimización: Modificados system version para que lleve información del iOS (compatibilidad con Android)
	    * Other: Apuntado a nuevo entorno en mymalcom.com

	* MCMConfig
	    * Feature: Actualización API con soporte para segmentación de usuarios

	* MCMNotifications
	    * Other: Modificada API de registro para compatibilidad con v2 de Malcom
	    * Bug: Corregido captura de NotificationId para medir la eficacia de las Push
	    * Optimización: Introducido autenticación HMAC

	* MCMStats
	    * Feature: Actualización API con soporte para envío de múltiples beacons
	    * Optimización: Eliminado envío directo a cola SQS. Ahora se hace a través del API con autenticación HMAC


v1.1.0 

Inclusión de AddOns, actualización de eventos del Core y mejoras en módulo de publicidad

	* MCAddons
	    * Feature: Incluida sección tipo Web
	    * Feature: Incluida sección tipo RSS/Atom de noticias
	    * Feature: Incluida sección tipo galería de fotos

	* MCMAd
	    * Feature: Soporte para APIs con opción de testMode
	    * Feature: Soporte para rotación
	    * Feature: Soporte para tamaños de banner no standard
	    * Feature: Agregada posibilidad de controlar aparición de publicidad a nivel de controlador mediante protocolo

	* MCMCore
	    * Other: Modificados los eventos del ModuleAdapter para simplificar y agregar rotaciones


v1.0.3

Inclusión de librerías de terceros en módulo de publicidad, distinción de entornos (developement/production) y otras pequeñas mejoras y bugs

	* MCMAd
	    * Feature: Incluida primera versión del módulo con publicidad de AdMob, iAd y inHouse

	* MCMConfig
	    * Bug: Creada UIWindow programáticamente si no estaba asignada desde .xib
	    * Bug: Utilizada correctamente la tabBar si ya se había creado por el developer
	    * Feature: Soporte para splash en iOS anteriores a 4.0
	    * Optimización: Evitada la carga de secciones si no está activo el módulo

	* MCMCore
	    * Feature: Agregada distinción entre entornos de desarrollo y producción

	* MCMStats
	    * Feature: Agregada información del carrier del dispositivo
	    * Feature: Agregado soporte para TouchJSON con parámetro de error

	* Example
	    * Bug: Corregido fallo en gestión de memoria de tags
	    * Feature: Agregado fichero de configuración apuntando a Malcom3 en modo debug
	    * Feature: Creado nuevo info-plist para tener dos apps diferentes según entorno apuntado


v1.0.2

Actualización del POC (mejoras gráficas y formatos RSS/Atom) y otras pequeñas mejoras y bugs

	* MCMAds
	    * Feature: Configurada librería de AdWhirl para apuntar a entorno Malcom
	    * Bug: Implementados delegados para evitar que la vista banner tape algún control mientras está cargando

	* MCMConfig
	    * Feature: Agregado parámetro infoMsgTimesToShow a las alertas para controlar número de repeticiones

	* MCMCore
	    * Bug: Corregido método de lenguaje para adaptarlo a ISO (ej: es)

	* MCMNotifications
	    * Feature: Extraída URL de conexión para apuntar a subdominio tipo apns.malcom

	*   Example
	    * Feature: Actualizado el POC con nueva librería de RSS y Atom
	    * Feature: Mejorada apariencia de visor de fotos
	    * Feature: Actualizado bundleId para nuevos certificados APNS

v1.0.1 

Resueltos varios bugs y optimizaciones en el módulo de configuración

	* MCMConfig
	    * Optimización: Implementado "if-cache" en peticiones para evitar transferencia de datos innecesaria
	    * Bug: Corregido error en splash screen en apps con controladores principales no estándar y que soporten rotación
	    * Feature: Agregada distinción en la carga de la imagen de Default de la  Splash según la orientación del dispositivo
	    * Bug: Corregido pequeño fallo por el cuál era posible que la splash no se llegara a descargar nunca si el usuario entraba y salía muy rápido de la app justo después de un cambio de imagen

