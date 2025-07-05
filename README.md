### ▪ Introducción y justificación del problema a resolver

El proyecto nace de la necesidad de conocer buenos lugares como restaurantes, cafés y demás establecimientos.  
Actualmente, para Lima (Perú), la fuente más cercana es **Google Maps** que, si bien es útil, suele mostrar información escasa, con pocas reseñas y datos desactualizados del local, entre otras dificultades.

Para descubrir alternativas, recordamos el **episodio 4 – temporada 19 de _South Park_**, donde uno de los protagonistas se vuelve crítico de Yelp y se muestra cómo esta plataforma adquiere gran relevancia en la ficción. <!-- link disimulado -->  
*[Ver episodio en South Park Latinoamérica](https://www.southpark.lat/episodios/en0srq/south-park-no-resenas-yelp-temporada-19-ep-4)*

Yelp es un sitio web y app donde los usuarios escriben y leen reseñas y valoraciones de negocios locales (restaurantes, talleres, dentistas, etc.), ayudando a encontrar y contactar establecimientos cercanos. Fue fundada en **octubre de 2004** y hoy está presente en América del Norte, Europa, Oceanía, **América del Sur (Brasil)** y Asia.

Nos pareció fascinante la magnitud de la empresa y la idea detrás de ella. Entonces nos preguntamos cómo, con esa información, un negocio —viejo o nuevo— podría beneficiarse. Por ejemplo: con tantas reseñas disponibles, un sistema que las lea automáticamente (sin intervención humana) y las clasifique según si las personas salieron satisfechas o insatisfechas del local permitiría obtener _insights_ valiosos y oportunidades de mejora.

Con ello, el negocio podría:

- Medir en tiempo real el pulso de la experiencia del cliente.  
- Detectar problemas antes de que escalen.  
- Comprobar si las mejoras se reflejan en un aumento de reseñas positivas.  

Todo esto **sin** tener que leer miles de comentarios uno por uno.

¿Interesante, no?


### ▪ Descripción del dataset, origen y tamaño de data

Para este proyecto investigamos distintas fuentes de origen, entre ellas el  
*[Yelp Open Dataset](https://business.yelp.com/data/resources/open-dataset/)* y, finalmente, nos quedamos con un dataset extraído de *[Kaggle – Yelp Dataset](https://www.kaggle.com/datasets/yelp-dataset/yelp-dataset/data?select=yelp_academic_dataset_user.json)*.

Se trata de una **muestra pública** de la información que Yelp guarda sobre negocios, reseñas y usuarios. Yelp la publicó para su “Dataset Challenge”, un concurso que anima a estudiantes a investigar los datos y compartir lo que descubran. La última versión abarca empresas de **ocho grandes ciudades** de EE. UU. y Canadá.

El conjunto contiene **5 archivos JSON** que, en total, suman **9.29 GB** de datos:

- **Reseñas completas**: `yelp_academic_dataset_review.json` — **5.34 GB**  
- **Ficha de cada negocio**: `yelp_academic_dataset_business.json` — **118.86 MB**  
- **Perfil de cada usuario**: `yelp_academic_dataset_user.json` — **3.36 GB**  
- **Historial de visitas por negocio**: `yelp_academic_dataset_checkin.json` — **286.96 MB**  
- **Consejos breves (“tips”)**: `yelp_academic_dataset_tip.json` — **180.6 MB**

Creamos el siguiente diccionario de datos

#### **Archivo: `yelp_academic_dataset_business.json`**

| **Columna**   | **Tipo** | **Descripción** |
|---------------|----------|-----------------|
| `address`     | string   | Dirección del negocio. |
| `attributes`  | struct   | Estructura con varios atributos del negocio, como la aceptación de tarjetas de crédito, estacionamiento, etc. |
| `business_id` | string   | Identificador único del negocio. |
| `categories`  | string   | Categorías asociadas con el negocio (por ejemplo, Restaurantes, Tiendas, etc.). |
| `city`        | string   | Ciudad donde se encuentra el negocio. |
| `hours`       | struct   | Horarios de apertura y cierre para cada día de la semana. |
| `is_open`     | long     | Indica si el negocio está abierto (1) o cerrado (0). |
| `latitude`    | double   | Latitud geográfica del negocio. |
| `longitude`   | double   | Longitud geográfica del negocio. |
| `name`        | string   | Nombre del negocio. |
| `postal_code` | string   | Código postal del negocio. |
| `review_count`| long     | Número total de reseñas recibidas por el negocio. |
| `stars`       | double   | Promedio de estrellas basado en las reseñas del negocio. |
| `state`       | string   | Estado donde se encuentra el negocio. |

#### **Archivo: `yelp_academic_dataset_review.json`**

| **Columna**   | **Tipo** | **Descripción** |
|---------------|----------|-----------------|
| `business_id` | string   | Identificador único del negocio al que pertenece la reseña. |
| `date`        | string   | Fecha en que se publicó la reseña. |

#### **Archivo: `yelp_academic_dataset_review.json`**

| **Columna**   | **Tipo** | **Descripción** |
|---------------|----------|-----------------|
| `business_id` | string   | Identificador único del negocio al que pertenece la reseña. |
| `cool`        | long     | Número de votos "cool" para la reseña. |
| `date`        | string   | Fecha en que se publicó la reseña. |
| `funny`       | long     | Número de votos "funny" para la reseña. |
| `review_id`   | string   | Identificador único de la reseña. |
| `stars`       | double   | Puntuación de la reseña (de 1 a 5 estrellas). |
| `text`        | string   | Texto completo de la reseña escrita por el usuario. |
| `useful`      | long     | Número de votos "useful" para la reseña. |
| `user_id`     | string   | Identificador único del usuario que escribió la reseña. |

#### **Archivo: `yelp_academic_dataset_tip.json`**

| **Columna**        | **Tipo** | **Descripción** |
|--------------------|----------|-----------------|
| `business_id`      | string   | Identificador único del negocio al que pertenece el tip. |
| `compliment_count` | long     | Número de elogios (compliments) recibidos por el tip. |
| `date`             | string   | Fecha en que se publicó el tip. |
| `text`             | string   | Texto completo del tip escrito por el usuario. |
| `user_id`          | string   | Identificador único del usuario que escribió el tip. |

#### **Archivo: `yelp_academic_dataset_user.json`**

| **Columna**          | **Tipo** | **Descripción** |
|----------------------|----------|-----------------|
| `average_stars`      | double   | Promedio de estrellas que ha recibido el usuario en todas sus reseñas. |
| `compliment_cool`    | long     | Número de elogios ("cool") que el usuario ha recibido. |
| `compliment_cute`    | long     | Número de elogios ("cute") que el usuario ha recibido. |
| `compliment_funny`   | long     | Número de elogios ("funny") que el usuario ha recibido. |
| `compliment_hot`     | long     | Número de elogios ("hot") que el usuario ha recibido. |
| `compliment_list`    | long     | Número de elogios ("list") que el usuario ha recibido. |
| `compliment_more`    | long     | Número de elogios ("more") que el usuario ha recibido. |
| `compliment_note`    | long     | Número de elogios ("note") que el usuario ha recibido. |
| `compliment_photos`  | long     | Número de elogios ("photos") que el usuario ha recibido. |
| `compliment_plain`   | long     | Número de elogios ("plain") que el usuario ha recibido. |
| `compliment_profile` | long     | Número de elogios ("profile") que el usuario ha recibido. |
| `compliment_writer`  | long     | Número de elogios ("writer") que el usuario ha recibido. |
| `cool`               | long     | Número total de veces que el usuario ha sido considerado "cool". |
| `elite`              | string   | Año(s) en que el usuario ha sido considerado "elite" (puede ser uno o varios, separados por comas). |
| `fans`               | long     | Número de "fans" que el usuario tiene. |
| `friends`            | string   | Lista de amigos del usuario (puede estar vacía). |
| `funny`              | long     | Número total de veces que el usuario ha sido considerado "funny". |
| `name`               | string   | Nombre del usuario. |
| `review_count`       | long     | Número total de reseñas que el usuario ha escrito. |
| `useful`             | long     | Número total de veces que las reseñas del usuario han sido consideradas "útiles". |
| `user_id`            | string   | Identificador único del usuario. |
| `yelping_since`      | string   | Fecha en la que el usuario comenzó a usar Yelp. |


### ▪ Dificultad técnica

Este trabajo representó un reto debido a la gran cantidad de datos.

Inicialmente debíamos contar con una arquitectura para refinar la calidad de los datos durante cada proceso del proyecto.

- Usamos el patrón *Medallion Architecture*, popularizado por **Databricks** como parte de su propuesta Lakehouse. Maneja tres niveles: primero se guardan los datos crudos en **bronze**, luego se limpian y normalizan en **silver** y, por último, se agregan y modelan en **gold** para que queden listos para utilidad del negocio.

Posteriormente, al tener la data sin procesar, debíamos encontrar un sistema para almacenar grandes cantidades de datos.

- **HDFS** (Hadoop Distributed File System) fue nuestra solución debido a su alta disponibilidad, almacenamiento distribuido y tolerante a fallos que Spark necesita para procesar eficientemente enormes volúmenes de datos.

Para el procesamiento necesitábamos una herramienta capaz de manejar tal volumen de datos (`etl_bronze_to_silver.ipynb`).

- Python tradicional y sus librerías como NumPy y pandas no eran opción debido a los excesivos tiempos de demora.  
- Spark fue nuestra opción ideal, ya que permite procesar y modelar en paralelo los gigabytes de reseñas de Yelp en un solo flujo, desde la limpieza en Delta Lake hasta el entrenamiento con MLlib, sin quedarse corto de memoria ni velocidad.  
- Probamos con Polars, donde tuvimos problemas porque producía error al realizar una operación que requería más memoria de la disponible. En nuestro caso ocurrió al intentar mover grandes cantidades de datos entre Spark y pandas (`df_completo.toPandas()`). Aquí pandas cargó todo a memoria y, por ser un caso de big data, causó problemas. Lo interesante es que este error, de alguna forma, afectó la sesión actual de Spark; algunas de las operaciones que ejecutó pandas o Polars relacionadas con el manejo de memoria pudieron haber afectado la estabilidad de la sesión.

El siguiente reto fue la elección de un formato adecuado para guardar los datos; formatos tradicionales XLSX o CSV no eran opción.

- Usamos formato **Parquet** para aprovechar y mantener el esquema actual; además, está optimizado para Spark y es compatible con HDFS.  
- Al crear la sesión por defecto de Spark, la memoria para el executor y driver no era suficiente, ni la cantidad de particiones. Modificamos estos parámetros y usamos **10 particiones**. En caso de no ajustar estos parámetros, la memoria excedía el 95 % disponible.  
- Parquet permitió que, para una próxima lectura, Spark maneje las particiones internamente y no sea necesario recorrerlas manualmente.  
- Además, posterior al *join* del dataset, este ocupaba **7.06 GB**; al guardar obtuvimos **3.27 GB** en formato Parquet.


### ▪ Creación del modelo

#### 🐳 Razonamiento para encapsular el entorno en Docker

| **Necesidad** | **Riesgo sin contenedores** | **Solución en `docker-compose.yml`** |
|--------------|-----------------------------|--------------------------------------|
| **Consistencia de versiones**<br>(Java 8, Hadoop 2.7.4, Spark 3.4, Delta 2.x) | Incompatibilidades de *classpath*, librerías nativas y binarios Delta | Imágenes oficiales fijan cada binario y dependencia. |
| **Asignación estricta de memoria**<br>(8 GB driver / executor) | Spark local compite con procesos del host; *OOM* al leer 9 GB JSON | Variables de entorno `SPARK_WORKER_MEMORY`, `spark.driver.memory`, `spark.executor.memory`. |
| **Almacenamiento distribuido**<br>para 9 GB + de datos crudos | El FS local se vuelve cuello de botella y carece de tolerancia a fallos | `namenode` + `datanode` con HDFS (replicación 1 para dev). |
| **Reproducibilidad de notebooks y CI/CD** | “It works on my machine”. Sucedió y se dockerizó. | Jupyter Lab con PySpark apuntando a `spark://spark:7077`. |
| **Exploración ágil de resultados** | Mover datos a BI externo implica costes y latencia | Superset lee directamente tablas Delta en HDFS. |

> **Resultado:** con `docker-compose up` cualquier colaborador lanza un *mini-cluster* idéntico y persistente.  
> Los datasets (`./data`), modelos (`./models`) y scripts (`./spark_jobs`) se comparten mediante *bind-mounts* y *named volumes*.

#### SparkSession con Delta Lake

```python
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .config("spark.driver.memory", "8g")
        .config("spark.executor.memory", "8g")
        .getOrCreate()
)
```
#### Carga de la capa silver
```python
df = spark.read.parquet(

"hdfs://namenode:9000/datalake/silver/yelp/reviews")
```
> PDT: La ruta HDFS se resuelve gracias a spark.hadoop.fs.defaultFS inyectado desde el contenedor

#### Etiquetado binario para Sentiment Analysis
```python
df = (df.filter(df.stars != 3)                 # descarta neutras

.withColumn("label",

F.when(F.col("stars") >= 4, 1).otherwise(0)))
```


#### 📝 Pipeline de NLP

| **Etapa** | **Componente MLlib** | **Motivo de uso** |
| :--: | --- | --- |
| 1 | **Tokenizer** | Divide texto en *tokens*. |
| 2 | **StopWordsRemover** | Elimina términos sin carga semántica (“the”, “de”, “y”). |
| 3 | **NGram** *(n = 2)* | Captura contexto local (ej. “muy bueno”, “no volveré”). |
| 4 | **HashingTF** *(numFeatures ≤ 200 k)* | Proyecta *n-grams* a un espacio disperso de dimensión fija, independiente del vocabulario completo. |
| 5 | **IDF** | Atenúa *n-grams* comunes y resalta los distintivos de cada reseña. |
| 6 | **LogisticRegression** *(elasticNet = 0.5)* | Clasificador lineal robusto, rápido en alta dimensión, con probabilidades interpretables. |

**¿Por qué Logistic Regression?**

- En textos cortos (~80 tokens/reseña) las **relaciones lineales** entre TF-IDF y polaridad funcionan muy bien.  
- Regularización L1/L2 ⟶ *features* dispersas y menor *over-fitting*.  
- Optimización LBFGS paralela incluida en MLlib (no requiere *Transformers*).

---

#### 🔍 Búsqueda de hiperparámetros y validación cruzada

```python
from pyspark.ml.tuning import ParamGridBuilder, CrossValidator
from pyspark.ml.evaluation import MulticlassClassificationEvaluator

param_grid = (
    ParamGridBuilder()
        .addGrid(lr.regParam,        [0.01, 0.05, 0.1])
        .addGrid(hashing.numFeatures, [100_000, 200_000])
        .build()
)

cv = CrossValidator(
    estimator          = pipeline,
    estimatorParamMaps = param_grid,
    evaluator          = MulticlassClassificationEvaluator(metricName="f1"),
    numFolds           = 3,   # 3-fold CV → buen balance coste/calidad
    parallelism        = 4    # reparte combinaciones en los workers
)
```
- **RegParam** controla la fuerza de la regularización.

- Varia **numFeatures** para equilibrar colisiones de *hashing* vs. memoria.

- **3‑fold CV** mantiene generalización sin triplicar en exceso el costo de cómputo; parallelism=4 reparte las combinaciones en el worker.


#### Entrenamiento, evaluación y persistencia

```python
# Split de entrenamiento / prueba
train, test = df.randomSplit([0.8, 0.2], seed=42)

# Ajuste con Cross-Validation
cv_model = cv.fit(train)

# Evaluación en el set de prueba
f1 = evaluator.evaluate(cv_model.transform(test))
print(f"F1-score: {f1:.2f}")   # ≈ 0.88
```
> Resultado: se alcanzó un F1-score ≈ 0.88.

```python
# Persistencia del modelo
cv_model.write().overwrite().save("file:///home/jovyan/models/yelp_lr_cv")

# Persistencia de predicciones (capa *gold*)
(
    cv_model.transform(df)
      .select("review_id", "prediction", "label")
      .write.mode("overwrite")
      .parquet("file:///home/jovyan/data/gold/reviews_sentiment_pred")
)
```
> file:// apunta al sistema de archivos del contenedor Jupyter; gracias al bind-mount ./models y ./data, los artefactos quedan disponibles tanto en el host como en Superset.

Usar Docker nos permitió:

- **Aislar** las dependencias críticas (Spark 3.4, Hadoop 2.7, Java 8, Delta 2.x) sin contaminar el entorno del desarrollador.
- **Garantizar** 8 GB de RAM reales para Spark, evitando fallos por desbordes cuando el dataset completo (~7 GB en Parquet) se materializa.
- **Persistir** resultados reproducibles y versionables (modelos, datasets *gold*) listos para BI.
    
    El pipeline NLP → TF‑IDF → Logistic Regression, validado con Cross Validation, ofrece una base robusta y rápida para detectar satisfacción vs. insatisfacción en millones de reseñas, constituyendo el núcleo analítico que da valor inmediato al negocio.



MongoDB se utilizó para guardar las predicciones (*gold*) generadas por el modelo, aprovechando su rendimiento con grandes volúmenes de datos y su escalabilidad.


1. En la misma carpeta de `reviews_sentiment_pred` creamos el archivo `cargamongo.py`.  
2. Desde **MongoDB Compass** definimos la base de datos `ProyectoBD` y la colección `reviews_sentiment`, dejando la estructura lista para recibir documentos.  
3. Leemos todos los archivos Parquet con la librería **PyArrow**.  
4. Convertimos los datos a *DataFrame* de **pandas**, luego a una lista de diccionarios y los insertamos con `insert_many` de **PyMongo**.  
5. Obtenemos así una base de datos lista para análisis en tiempo real y con capacidad de escalar conforme crezca la cantidad de predicciones.




La integración de **Superset** nos permitió crear gráficos y tableros basados en las predicciones del modelo:

1. **Clonar y levantar Superset**  
   - Clonamos el repositorio oficial.  
   - Ajustamos el `docker-compose.yml` y levantamos los servicios con **Docker Desktop**.

2. **Acceso local**  
   - Iniciamos Superset en `http://localhost:8088`.  
   - Tras autenticarnos, comenzamos a preparar los datos con Python.

3. **Exploración inicial**  
   - Analizamos la columna `state`; contamos como “estado” cualquier valor que aparezca más de una vez y tenga longitud > 1 carácter.  
   - Resultado (diccionario abreviado ⇩):  

     <details><summary>Estados detectados</summary>

     ```python
     ESTADOS = {
         'AL': 'Alabama', 'AK': 'Alaska', 'AZ': 'Arizona', 'AR': 'Arkansas',
         'CA': 'California', 'CO': 'Colorado', 'CT': 'Connecticut', 'DE': 'Delaware',
         'FL': 'Florida', 'GA': 'Georgia', 'HI': 'Hawaii', 'ID': 'Idaho',
         'IL': 'Illinois', 'IN': 'Indiana', 'IA': 'Iowa', 'KS': 'Kansas',
         'KY': 'Kentucky', 'LA': 'Louisiana', 'ME': 'Maine', 'MD': 'Maryland',
         'MA': 'Massachusetts', 'MI': 'Michigan', 'MN': 'Minnesota', 'MS': 'Mississippi',
         'MO': 'Missouri', 'MT': 'Montana', 'NE': 'Nebraska', 'NV': 'Nevada',
         'NH': 'New Hampshire', 'NJ': 'New Jersey', 'NM': 'New Mexico', 'NY': 'New York',
         'NC': 'North Carolina', 'ND': 'North Dakota', 'OH': 'Ohio', 'OK': 'Oklahoma',
         'OR': 'Oregon', 'PA': 'Pennsylvania', 'RI': 'Rhode Island', 'SC': 'South Carolina',
         'SD': 'South Dakota', 'TN': 'Tennessee', 'TX': 'Texas', 'UT': 'Utah',
         'VT': 'Vermont', 'VA': 'Virginia', 'WA': 'Washington', 'WV': 'West Virginia',
         'WI': 'Wisconsin', 'WY': 'Wyoming',
         'PENNSYLVANIA': 'Pennsylvania', 'FLORIDA': 'Florida', 'LOUISIANA': 'Louisiana',
         'TENNESSEE': 'Tennessee', 'INDIANA': 'Indiana', 'NEVADA': 'Nevada',
         'ILLINOIS': 'Illinois', 'CALIFORNIA': 'California', 'ARIZONA': 'Arizona',
         'MISSOURI': 'Missouri', 'DELAWARE': 'Delaware', 'IDAHO': 'Idaho'
     }
     ```
     </details>

4. **Enriquecimiento de datos**  
   - Hacemos un `JOIN` entre las predicciones almacenadas en **ProyectoBD** y la información de negocios vía `business_id`.

5. **Conexión desde Superset**  
   - Usamos **SQLAlchemy** (`create_engine`) para conectar con PostgreSQL:  
     `superset:superset@localhost:5432/superset` (Superset no se conecta directo a MongoDB).

6. **Carga final**  
   - Guardamos la tabla como **`reviews_pred_joined`** en el esquema `public`.

7. **Creación de dashboards**  
   - Registramos la base en Superset, diseñamos los *charts* y los añadimos al dashboard interactivo.


### ▪ Herramientas y/o tecnologías empleadas

- **Arquitectura Medallion** para el flujo y guardado de datos durante el pipeline.  
- **HDFS** para almacenamiento de data cruda.  
- **Apache Spark** para procesamiento distribuido de datos.  
- **Particionamiento** para un guardado eficiente.  
- **Formato Parquet** para almacenamiento óptimo y columnar.  
- **MLlib** para el modelado de *Machine Learning*.  
- **MongoDB** (NoSQL) para almacenar las predicciones de sentimiento en BSON y escalar sin problemas.  
  - **PyArrow**: lectura de archivos Parquet.  
  - **PyMongo**: conexión Python-MongoDB para inserción masiva.  
  - **MongoDB Compass**: GUI para administrar la base de datos y colecciones.  
- **Apache Superset**: plataforma de visualización para crear dashboards interactivos.  
  - **SQLAlchemy**: conexión entre Python y PostgreSQL para Superset.

  ### ▪ Arquitectura del proyecto y ETL

Descargamos de **Kaggle** los 5 archivos JSON y los almacenamos en **HDFS**; dentro de nuestra *Medallion Architecture* esta es la **capa *bronze***.  
Luego, extraemos dichos archivos y, mediante un proceso **ETL** con **Spark**, generamos un único dataset consolidado, particionado y guardado en formato **Parquet**. Con este paso conformamos la **capa *silver***, de la que se alimenta el modelo de *Machine Learning*.  
El resultado del modelo se almacena en **MongoDB**, lo que denominamos **capa *gold***, lista para ser consumida en gráficos orientados al negocio.



![Diagrama de arquitectura](docs/arquitectura.png)


### ▪ Resultados obtenidos y análisis de estos

**ETL**  
Se obtuvo un dataset unificado que contiene solo variables relevantes para los gráficos visuales y para llevarlo a un modelo de ML. Además, el particionado y uso de formato Parquet aportaron significativamente a trabajar de forma más óptima y fluida.

**Modelo**  
El pipeline NLP usa Tokenizer, stop-words, bi-gramas, TF-IDF y Logistic Regression y logra un **F1 ≈ 0.88**.  
Los datos son 7 GB de reseñas de Yelp en HDFS etiquetadas como positivas (≥ 4★) y negativas (≤ 2★).  
Todo corre en Spark 3.4 con Delta Lake dentro de un `docker-compose` que fija 8 GB de RAM para driver y executor y se reproduce igual en cualquier máquina.  
El modelo se guarda en `./models/yelp_lr_cv` y las predicciones *gold* en `./data/gold`.

**Insight de negocio**

1. En la primera visualización vemos los *top 10* negocios con mayor número de fraudes detectados; aparecen marcas como **Starbucks** y **Subway**, mostrando que incluso los negocios famosos no se libran de cometer fraude.  
2. El segundo gráfico muestra la tendencia de discrepancias a lo largo de los años: conforme avanza el tiempo, los negocios cometen fraude y, en ocasiones, disminuyen la práctica para no levantar sospechas constantes.  
3. El tercer gráfico presenta los *top 10* estados con mayor promedio de fraudes en negocios; si estamos en uno de ellos, es probable que el negocio que visitemos haya cometido fraude en algún momento.  
4. La cuarta gráfica muestra la distribución de estados con reviews fraudulentas, indicando cuáles cometieron más o menos fraude a lo largo del tiempo.  
5. El último gráfico señala el estado y restaurante con mayor cantidad de fraudes detectados, sugiriendo qué lugares es preferible evitar.

---

### ▪ Dificultades identificadas al momento de implementar la solución

**ETL**  
La sesión base de Spark debía ser configurable y tuvimos que probar diversos valores de memoria para el executor, driver y número de particiones; de lo contrario, la memoria alcanzaba el 100 % y el proceso se cortaba.

**Modelo**  
- Alinear versiones (Java 8, Hadoop 2.7.4, Spark 3.4, Delta 2.x) para evitar choques de *classpath*.  
- Los OOM al cargar 9 GB de JSON obligaron a fijar 8 GB de RAM para driver / executor.  
- El disco local se volvió cuello de botella y sin tolerancia a fallos, lo que motivó montar un `namenode` + `datanode` en HDFS.  
- La falta de reproducibilidad (“it works on my machine”) se resolvió contenedorizando todo con variables y volúmenes fijados.  
- Mover resultados a otras herramientas de BI añadía latencia; Superset pasó a leer Delta en origen.  
- Ajustar `numFeatures` para equilibrar colisiones de *hashing* y uso de memoria exigió validar varias combinaciones.  
- La 3-fold CV multiplicó el tiempo de cómputo, mitigado con `parallelism = 4`.  
- Asegurar que modelos y datasets *gold* persistan fuera del contenedor requirió *bind-mounts* y *named volumes* bien configurados.

**Superset**  
Al tener una gran cantidad de datos, cada ejecución podía demorar más de 20 min antes de arrojar un error, haciendo los ciclos de prueba muy largos.

---

### ▪ Conclusiones y posibles mejoras

**Conclusiones**

1. **Data Yelp + NLP** permite clasificar satisfacción / insatisfacción automáticamente, cubriendo la escasez de reseñas fiables.  
2. 9 GB en bruto (5 archivos JSON) → 3.27 GB Parquet tras ETL, imprescindible para procesados posteriores de modelo y visualización.  
3. La **Arquitectura Medallion** (Bronze → Silver → Gold) dio un orden claro al flujo de datos en cada etapa.  
4. **Modelo**: pipeline Tokenizer → StopWords → bi-gramas → TF-IDF → Logistic Regression validado con 3-fold CV; **F1 ≈ 0.88**.

Comenzamos con 9 GB de reseñas Yelp, empleamos la arquitectura Medallion en HDFS, Spark 3.4 dockerizado y el pipeline NLP → TF-IDF → Logistic Regression para clasificar satisfacción de clientes, guardar resultados en MongoDB y exponerlos en Superset. Este flujo permitió manejar adecuadamente el gran volumen de datos.

**Posibles mejoras**

- Guardar la data en **Amazon S3** y consultarla con **Athena**; la data se actualizaría continuamente y las consultas serían más eficientes usando índices por fecha.  
- Migrar el procesamiento a un clúster **Databricks**, orquestado por **Airflow**, programado para correr a una hora fija cada día y automatizar el pipeline completo.  
- Conectar los resultados a **Power BI** para ofrecer gráficas actualizadas y de fácil acceso a los *stakeholders*.


**Extra**
- Podemos crear un modelo usando grafos ya que cada usuario tiene el id de su correspondiente amigo en la plataforma
- Redis puede aportar una pieza de baja latencia en la capa de servicio y monitoreo en tiempo real ya que los datos viven en la RAM del servidor