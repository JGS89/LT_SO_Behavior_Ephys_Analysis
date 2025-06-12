# 🧠 Análisis de comportamiento y actividad neuronal — Linear Track + Social-Objeto (SO)

Este repositorio contiene funciones y scripts para el procesamiento, sincronización y análisis de sesiones experimentales en ratones, realizadas en un laberinto lineal (*Linear Track*) con exposición a estímulos sociales y de objeto (**SO**) en los extremos.

Incluye herramientas para el preprocesamiento de datos crudos, detección de eventos TTL, alineamiento de señales, etiquetado de neuronas y estructuración de sesiones.

---

## ⚙️ Funciones incluidas

| Script                             | Descripción breve                                                                 |
|------------------------------------|-----------------------------------------------------------------------------------|
| `convertir_clu_res_a_txt.m`       | Convierte archivos `.clu` y `.res` de Klusters a formato de texto exportable       |
| `convertir_rhd_a_dat.m`           | Extrae señales desde archivos `.rhd` de Intan y los guarda en formato `.dat`.      |
| `detectar_TTL_openmv.m`           | Detecta pulsos TTL de sincronización entre OpenMV y el sistema de adquisición.     |
| `resample_tracking_anymaze.m`     | Reinterpolación del tracking exportado desde AnyMaze a una frecuencia deseada.     |
| `tag_neuronas_zscore_SO.m`        | Clasifica neuronas en selectivas a estímulo Social, Objeto o No selectivas.        |
| `funcion_intervalos.m`            | Genera intervalos de interés a partir de la posición del animal en la pista.       |
| `LT_Reescalar.m`                  | Reescala coordenadas del trayecto lineal para facilitar análisis posteriores.      |
| `calculo_intervalos_SO.m`         | Calcula intervalos de permanencia y corrida en extremos Social y Objeto.           |
| `generador_sesion_plantilla.m`    | Crea una plantilla `.mat` con variables organizadas para análisis posteriores.     |

---

## 📌 Aplicación

Estas herramientas están diseñadas para ser usadas en tareas del tipo **Social–Objeto (SO)** realizadas en un **Linear Track**, con datos provenientes de:

- Adquisición de señales electrofisiologicas in-vivo con Tetrodos (Intan RHD2132)
- Spike sorting con **Neurosuite** (https://neurosuite.sourceforge.net/)
- Tracking con **ANY-maze v4.98 4**
- Sincronización por pulsos TTL (OpenMV Cam7, OpenMV IDE v4.0.1)

- Este analisis fue utilizado en el trabajo de tesis doctoral:
  *Gonzalez Sanabria, Javier Alberto. (2023). Rol de la corteza prefrontal medial en la codificación de información contextual en un modelo murino de esquizofrenia.* (Tesis Doctoral. Universidad de Buenos Aires. Facultad de Ciencias Exactas y Naturales.). Recuperado de https://hdl.handle.net/20.500.12110/tesis_n7442_GonzalezSanabria

---

## 🧪 Requisitos

- MATLAB R2017a

---

## 👨‍🔬 Autor

**Javier Gonzalez Sanabria, PhD**  
*IFIBIO Houssay (UBA-CONICET), FMED, UBA*  
Desarrollado en colaboración con **Maria Florencia Santos**  
Contacto: javiergs89@gmail.com

---

## 📃 Licencia

Este código se distribuye con fines académicos y de investigación. Para otros usos, por favor contactar al autor.
