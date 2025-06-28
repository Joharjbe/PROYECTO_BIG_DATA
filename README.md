Propuesta 🅰️ “Sentiment & Rating Predictor”

Objetivo:
- El objetivo del proyecto es predecir el sentimiento (positivo/negativo) y las estrellas (de 1 a 5) de las reseñas de Yelp.
- Este modelo puede servir para automatizar el análisis de las reseñas, detectar posibles fraudes (por ejemplo, una reseña muy positiva con pocas estrellas) o ayudar a los negocios a entender la calidad del servicio según las opiniones de los usuarios.

1. Problema a resolver
	•	Automatizar la predicción de estrellas (1-5) y sentimiento en texto libre de cada nueva reseña.
	•	Detectar incongruencias (ej. reseña muy positiva con pocas estrellas) para alertar de posibles fraudes o errores.

2. Datos usados
Archivo JSON
Motivo / campos principales
yelp_academic_dataset_review.json (5.3 GB)
text, stars, business_id, user_id, date → features y etiqueta del modelo.
yelp_academic_dataset_business.json (119 MB)
name, city, state, categories, coordenadas → contexto para dashboards.
yelp_academic_dataset_user.json (3.3 GB)
review_count, yelping_since, elite → features adicionales o filtros.
(Opcional) checkin.json
número de visitas del negocio como feature numérico.


3. Arquitectura detallada
┌────────────────────────────────────────────┐
│               Usuario / Admin             │
│  (descarga manual de Yelp ZIP y lo copia  │
│     a /datalake/bronze en HDFS)           │
└────────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────┐
│            HDFS – Capa Bronze              │
│  • 5 JSON intactos                         │
│  Ruta: /datalake/bronze/yelp/*.json        │
└────────────────────────────────────────────┘
                │  (Airflow detecta nuevo lote)
                ▼
┌────────────────────────────────────────────┐
│        Spark ETL — Capa Silver (Delta)     │
│  • Limpieza, normalización de fechas       │
│  • Column pruning                          │
│  • Partición por year=YYYY/month=MM        │
│  Ruta: /datalake/silver/yelp               │
└────────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────┐
│  Spark ML — Capa Gold (Delta + Modelos)    │
│  • TF–IDF + Logistic Regression            │
│  • Tabla de predicciones + flag fraude     │
│  Ruta preds: /datalake/gold/reviews_pred   │
│  Ruta modelo: /models/yelp_lr.zip          │
└────────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────┐
│            MongoDB (Serving layer)         │
│  • Colección reviews_pred                  │
│    – review_id, business_id, user_id       │
│    – star_real, star_pred, sentiment, flag │
└────────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────┐
│            Superset Dashboards             │
│  • Discrepancias star vs sentiment         │
│  • Calor por ciudad / categoría            │
│  • Ranking de negocios sospechosos         │
└────────────────────────────────────────────┘


4. Flujo operativo con Airflow (DAG)
Orden
Tarea (Airflow)
Acción principal
Output
0
sensor_bronze
Detecta JSON nuevos en /datalake/bronze
trigger
1
spark_to_silver
spark-submit etl_bronze_to_silver.py
Delta Silver
2
spark_train_pred
spark-submit train_predict.py
Delta Gold + modelo
3
spark_to_mongo
Graba /gold/reviews_pred en MongoDB
Colección actualizada
4
superset_refresh
Llama API para recalcular datasets
Dash actualizado




4. Pipeline propuesto
	1.	Carga manual → HDFS (Bronze)
	•	Descargas los 5 JSON de Yelp y los copias a /datalake/bronze/yelp en HDFS.
	•	Sirven como “fuente de verdad” sin tocar.
	2.	ETL Bronze → Silver (etl_bronze_to_silver.py)
	•	etl_bronze_to_silver.py lee los JSON, limpia tipos de dato, normaliza fechas y selecciona solo las columnas necesarias.
	•	Escribe en formato Delta Lake particionado por year/month en /datalake/silver/yelp.
    3.	Feature engineering + modelo (Spark MLlib) → Delta Gold | (train_predict.py)
	•	Carga silver, filtra reseñas ≥ 50 caracteres.
	•	Tokenizer → HashingTF → IDF → LogisticRegression.
	•	Registra métricas (accuracy, F1) en logs.
	•	Predice sobre todo el conjunto y escribe Delta Gold.
    •	train_predict.py toma la capa Silver, genera TF-IDF y entrena Logistic Regression para predecir estrellas y sentimiento.
	•	Guarda el modelo (/models/yelp_lr.zip) y las predicciones en /datalake/gold/reviews_pred.
	4.	Carga a MongoDB
	•	Conector Spark-Mongo:
    •	Un job Spark usa el conector mongo-spark-connector para insertar la tabla reviews_pred en la colección yelp.reviews_pred.
    5.	Visualización (Superset)
    •   Superset se conecta a MongoDB y muestra dashboards: discrepancias star/sentiment, mapa por ciudad, ranking de negocios sospechosos.
	•	Datasource: mongodb://mongo:27017/yelp.reviews_pred
	•	Tres visuales mínimas:
        1.	Mapa de calor de discrepancia por estado.
        2.	Serie temporal de % fraude detectado.
        3.	Tabla top 20 negocios con más flags.
    6.	Orquestación con Airflow
	•	DAG encadena las tareas: sensor_bronze → spark_to_silver → spark_train_pred → spark_to_mongo → superset_refresh.


5. Herramientas (6 exactas)

Herramienta
Rol en la solución
Hadoop / HDFS
Data Lake bronze (archivos crudos).
Delta Lake
Formato ACID para capas silver & gold.
Apache Spark (+ MLlib)
ETL, feature engineering y modelo.
Apache Airflow
Orquestación de todo el pipeline.
MongoDB
Capa de serving de resultados.
Apache Superset
Cuadros de mando interactivos.


---

Ruta “nativa” (sin Docker)
Menos sobrecarga si usas un solo equipo potente y prefieres control total.Instalas herramientas una por una.


Estrucutra de carpetas
yelp_project/
│
├─ data/                       # “Data Lake” local ─ NO se sube a Git
│   ├─ bronze/                 # 5 JSON originales (raw)
│   ├─ silver/                 # Tablas Delta limpias
│   └─ gold/                   # Predicciones + flags
│
├─ dags/                       # Airflow DAGs (*.py)
│   └─ yelp_pipeline.py
│
├─ spark_jobs/                 # Scripts PySpark
│   ├─ etl_bronze_to_silver.py
│   └─ train_predict.py
│
├─ models/                     # Modelos MLlib exportados (.zip)
│   └─ yelp_lr.zip             # (creado por pipeline)
│
├─ notebooks/                  # Exploración EDA opcional (Jupyter / VS Code)
│   └─ eda_overview.ipynb
│
├─ superset/                   # Artefactos BI
│   ├─ dashboard_export.json   # export de Superset
│   └─ dataset_metadata.json
│
├─ scripts/                    # Utilidades (ej. carga-mongo.py)
│
├─ docs/                       # Documentación para entrega
│   ├─ arquitectura_drawio.png
│   └─ presentación.pptx
│
├─ .gitignore                  # excluye data/, *.zip, *.tgz…
├─ requirements.txt            # Airflow, Superset, Delta-Spark, MongoDriver
├─ README.md                   # guía paso a paso (entregable)
└─ LICENSE                     # MIT o la que elijan

---

### Diccionario de Datos

#### **Archivo: `yelp_academic_dataset_business.json`**

| **Columna**             | **Tipo**        | **Descripción**                                                                                         |
|-------------------------|-----------------|---------------------------------------------------------------------------------------------------------|
| `address`               | string          | Dirección del negocio.                                                                                  |
| `attributes`            | struct          | Estructura con varios atributos del negocio, como la aceptación de tarjetas de crédito, estacionamiento, etc. |
| `business_id`           | string          | Identificador único del negocio.                                                                         |
| `categories`            | string          | Categorías asociadas con el negocio (por ejemplo, Restaurantes, Tiendas, etc.).                           |
| `city`                  | string          | Ciudad donde se encuentra el negocio.                                                                   |
| `hours`                 | struct          | Horarios de apertura y cierre para cada día de la semana.                                                |
| `is_open`               | long            | Indica si el negocio está abierto (1) o cerrado (0).                                                    |
| `latitude`              | double          | Latitud geográfica del negocio.                                                                         |
| `longitude`             | double          | Longitud geográfica del negocio.                                                                        |
| `name`                  | string          | Nombre del negocio.                                                                                     |
| `postal_code`           | string          | Código postal del negocio.                                                                              |
| `review_count`          | long            | Número total de reseñas recibidas por el negocio.                                                       |
| `stars`                 | double          | Promedio de estrellas basado en las reseñas del negocio.                                                 |
| `state`                 | string          | Estado donde se encuentra el negocio.                                                                   |


#### **Archivo: `yelp_academic_dataset_review.json`**

| **Columna**             | **Tipo**        | **Descripción**                                                                                         |
|-------------------------|-----------------|---------------------------------------------------------------------------------------------------------|
| `business_id`           | string          | Identificador único del negocio al que pertenece la reseña.                                              |
| `date`                  | string          | Fecha en que se publicó la reseña.                                                                       |



#### **Archivo: `yelp_academic_dataset_review.json`**

| **Columna**             | **Tipo**        | **Descripción**                                                                                         |
|-------------------------|-----------------|---------------------------------------------------------------------------------------------------------|
| `business_id`           | string          | Identificador único del negocio al que pertenece la reseña.                                              |
| `cool`                  | long            | Número de votos "cool" para la reseña.                                                                   |
| `date`                  | string          | Fecha en que se publicó la reseña.                                                                       |
| `funny`                 | long            | Número de votos "funny" para la reseña.                                                                  |
| `review_id`             | string          | Identificador único de la reseña.                                                                        |
| `stars`                 | double          | Puntuación de la reseña (de 1 a 5 estrellas).                                                           |
| `text`                  | string          | Texto completo de la reseña escrita por el usuario.                                                     |
| `useful`                | long            | Número de votos "useful" para la reseña.                                                                |
| `user_id`               | string          | Identificador único del usuario que escribió la reseña.                                                 |



#### **Archivo: `yelp_academic_dataset_tip.json`**

| **Columna**             | **Tipo**        | **Descripción**                                                                                         |
|-------------------------|-----------------|---------------------------------------------------------------------------------------------------------|
| `business_id`           | string          | Identificador único del negocio al que pertenece el tip.                                                 |
| `compliment_count`      | long            | Número de elogios (compliments) recibidos por el tip.                                                    |
| `date`                  | string          | Fecha en que se publicó el tip.                                                                          |
| `text`                  | string          | Texto completo del tip escrito por el usuario.                                                          |
| `user_id`               | string          | Identificador único del usuario que escribió el tip.                                                    |


#### **Archivo: `yelp_academic_dataset_user.json`**

| **Columna**             | **Tipo**        | **Descripción**                                                                                         |
|-------------------------|-----------------|---------------------------------------------------------------------------------------------------------|
| `average_stars`         | double          | Promedio de estrellas que ha recibido el usuario en todas sus reseñas.                                    |
| `compliment_cool`       | long            | Número de elogios ("cool") que el usuario ha recibido.                                                   |
| `compliment_cute`       | long            | Número de elogios ("cute") que el usuario ha recibido.                                                   |
| `compliment_funny`      | long            | Número de elogios ("funny") que el usuario ha recibido.                                                  |
| `compliment_hot`        | long            | Número de elogios ("hot") que el usuario ha recibido.                                                   |
| `compliment_list`       | long            | Número de elogios ("list") que el usuario ha recibido.                                                  |
| `compliment_more`       | long            | Número de elogios ("more") que el usuario ha recibido.                                                  |
| `compliment_note`       | long            | Número de elogios ("note") que el usuario ha recibido.                                                  |
| `compliment_photos`     | long            | Número de elogios ("photos") que el usuario ha recibido.                                                |
| `compliment_plain`      | long            | Número de elogios ("plain") que el usuario ha recibido.                                                 |
| `compliment_profile`    | long            | Número de elogios ("profile") que el usuario ha recibido.                                               |
| `compliment_writer`     | long            | Número de elogios ("writer") que el usuario ha recibido.                                                |
| `cool`                  | long            | Número total de veces que el usuario ha sido considerado "cool".                                         |
| `elite`                 | string          | Año(s) en el que el usuario ha sido considerado "elite". (Puede ser un solo año o varios años separados por comas). |
| `fans`                  | long            | Número de "fans" que el usuario tiene.                                                                  |
| `friends`               | string          | Lista de amigos del usuario. (Puede estar vacía).                                                       |
| `funny`                 | long            | Número total de veces que el usuario ha sido considerado "funny".                                       |
| `name`                  | string          | Nombre del usuario.                                                                                     |
| `review_count`          | long            | Número total de reseñas que el usuario ha escrito.                                                     |
| `useful`                | long            | Número total de veces que las reseñas del usuario han sido consideradas "útiles".                        |
| `user_id`               | string          | Identificador único del usuario.                                                                        |
| `yelping_since`         | string          | Fecha en la que el usuario comenzó a usar Yelp.                                                         |




---


# VARIABLES por archivo

1. yelp_academic_dataset_review.json (Reseñas)

Variables importantes:
	•	review_id: Identificador único de la reseña.
	•	text: El texto completo de la reseña (esto lo utilizarás para el análisis de sentimiento).
	•	stars: Las estrellas reales que un usuario da a la reseña (1-5) que usarás como tu etiqueta para la predicción.
	•	user_id: El identificador del usuario que hizo la reseña (puede ser útil para agregar más contexto sobre el usuario).
	•	business_id: El identificador del negocio que recibe la reseña.
    •	date

2. yelp_academic_dataset_user.json (Información sobre el usuario)

Variables importantes:
	•	user_id: Identificador único del usuario (te servirá para hacer join con el archivo de reseñas).
	•	review_count: Número de reseñas escritas por el usuario (puede ser útil para agregar contexto al comportamiento del usuario).
	•	average_stars: Promedio de estrellas que ha dado el usuario a sus reseñas anteriores (esto puede ayudar a entender si un usuario tiende a ser más positivo o negativo).
	•	yelping_since: Fecha en la que el usuario comenzó a usar Yelp (puede ayudar a calcular la antigüedad del usuario).

3. yelp_academic_dataset_business.json (Información sobre el negocio)

Variables importantes:
	•	business_id: Identificador único del negocio (te servirá para hacer join con las reseñas).
	•	name: Nombre del negocio (aunque no es necesario para el modelo, puede ser útil para los dashboards).
	•	city y state: Ciudad y estado del negocio (esto será útil si quieres hacer análisis geográficos o agrupaciones por ciudad/estado).
    •	latitude y longitude : Para graficar en mapa
	•	categories: Categorías del negocio (como restaurantes, bares, etc. Esto puede ser útil como característica adicional).
	•	stars: Promedio de estrellas del negocio (puedes usarlo como una característica del negocio para ayudar a predecir las estrellas de la reseña). 
    •	review_count: Número total de reseñas del negocio. Esto podría correlacionar con la confianza o popularidad del negocio, y podría ser útil como característica adicional.




---


- Consumir Hadoop (json) -> Jyns
- Modelado -> Jyns
- MongoDB -> Cris 
- Visulización -> Cris / Johar
- Airflow -> Cris

Johar ->
- Doc
- PPT
- Readme

┌────────────────────────────────────────────┐
│               Usuario / Admin             │
│  (descarga manual de Yelp ZIP y lo copia  │
│     a /datalake/bronze en HDFS)           │
└────────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────┐
│            HDFS – Capa Bronze              │
│  • 5 JSON intactos                         │
│  Ruta: /datalake/bronze/yelp/*.json        │
└────────────────────────────────────────────┘
                │  (Airflow detecta nuevo lote)
                ▼
┌────────────────────────────────────────────┐
│        Spark ETL — Capa Silver (Delta)     │
│  • Limpieza, normalización de fechas       │
│  • Column pruning                          │
│  • Partición por year=YYYY/month=MM        │
│  Ruta: /datalake/silver/yelp               │
└────────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────┐
│  Spark ML — Capa Gold (Delta + Modelos)    │
│  • TF–IDF + Logistic Regression            │
│  • Tabla de predicciones + flag fraude     │
│  Ruta preds: /datalake/gold/reviews_pred   │
│  Ruta modelo: /models/yelp_lr.zip          │
└────────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────┐
│            MongoDB (Serving layer)         │
│  • Colección reviews_pred                  │
│    – review_id, business_id, user_id       │
│    – star_real, star_pred, sentiment, flag │
└────────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────┐
│            Superset Dashboards             │
│  • Discrepancias star vs sentiment         │
│  • Calor por ciudad / categoría            │
│  • Ranking de negocios sospechosos         │
└────────────────────────────────────────────┘