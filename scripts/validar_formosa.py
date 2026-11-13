# Revisamos las preinscripciones del Excel de Formosa sin conectarnos a PostgreSQL.
# Generamos JSON con solicitudes válidas y pendientes para la posterior carga SQL.
from pathlib import Path
from datetime import date, datetime
from collections import Counter
import json
import re
import unicodedata

from openpyxl import load_workbook


# ubico los archivos tomando como referencia la carpeta del proyecto
RAIZ = Path(__file__).resolve().parent.parent
ARCHIVO = RAIZ / "datos" / "preinscripciones_formosa.xlsx"
SALIDA = RAIZ / "resultados"


def texto(valor):
    """convierto un valor a texto y quito espacios sobrantes."""
    return "" if valor is None else str(valor).strip()


def normalizar(valor):
    """unifico mayúsculas, espacios y acentos para comparar materias."""
    contenido = unicodedata.normalize("NFD", texto(valor))
    sin_acentos = "".join(
        letra for letra in contenido
        if unicodedata.category(letra) != "Mn"
    )
    return " ".join(sin_acentos.upper().split())


# Coordinamos la lectura, la revisión de cada fila y la escritura de los resultados.
def main():
    # leo el archivo sin modificar el Excel original
    libro = load_workbook(ARCHIVO, read_only=True, data_only=False)

    try:
        hoja = libro["Preinscripciones"]

        encabezados_esperados = [
            "Solicitud", "Fecha de solicitud", "Legajo",
            "Nombre", "Apellido", "Materia informada",
            "Período", "Comisión", "Observaciones"
        ]

        encabezados = [
            texto(celda.value) for celda in hoja[6][:9]
        ]

        # Si cambia el formato del Excel, detenemos la lectura para no confundir las columnas.
        if encabezados != encabezados_esperados:
            raise ValueError(
                "Los encabezados de la fila 6 no coinciden con lo esperado."
            )

        # la tabla termina en la primera fila completamente vacía
        filas = []
        for numero, valores in enumerate(
            hoja.iter_rows(min_row=7, max_col=9, values_only=True),
            start=7
        ):
            if all(texto(valor) == "" for valor in valores):
                break
            filas.append((numero, valores))

        # Contamos primero todos los identificadores: cada aparición de uno repetido queda pendiente.
        solicitudes = Counter(
            texto(valores[0]) for _, valores in filas
        )

        validas = []
        pendientes = []

        for numero, valores in filas:
            (
                solicitud, fecha, legajo, nombre, apellido,
                materia, periodo, comision, observaciones
            ) = valores

            solicitud = texto(solicitud)
            legajo = texto(legajo).upper()
            nombre = texto(nombre)
            apellido = texto(apellido)
            periodo = texto(periodo)
            comision = texto(comision).upper()
            errores = []

            if not re.fullmatch(r"FOR-SOL-\d+", solicitud):
                errores.append("Identificador de solicitud inválido")

            if solicitudes[solicitud] > 1:
                errores.append("Identificador de solicitud repetido")

            if not legajo:
                errores.append("Falta el legajo")
            elif not re.fullmatch(r"FOR-\d+", legajo):
                errores.append("El legajo no tiene el formato FOR-número")

            if not nombre or not apellido:
                errores.append("Falta nombre o apellido")

            if not isinstance(fecha, (date, datetime)):
                errores.append("Fecha de solicitud inválida")

            materias_admitidas = {
                "GABD",
                "GESTION AVANZADA DE BASES DE DATOS"
            }

            if normalizar(materia) not in materias_admitidas:
                errores.append("Materia no reconocida")

            # estos son el período y la comisión preparados para esta prueba
            if periodo != "2026-2":
                errores.append("Período no previsto para esta prueba")

            if comision != "A":
                errores.append("Comisión no prevista para esta prueba")

            # Juntamos los motivos y dejamos la fila para revisión, sin frenar las demás.
            if errores:
                pendientes.append({
                    "fila_excel": numero,
                    "solicitud": solicitud,
                    "nombre": nombre,
                    "apellido": apellido,
                    "motivos": errores
                })
                print(
                    f"PENDIENTE | {solicitud} | "
                    f"{'; '.join(errores)}"
                )
                continue

            fecha_solicitud = (
                fecha.date() if isinstance(fecha, datetime) else fecha
            )

            # Armamos los campos que espera el importador SQL, con fecha en formato año-mes-día.
            # La base vuelve a validar referencias y controla lo que ya se importó en cargas anteriores.
            validas.append({
                "solicitud": solicitud,
                "legajo": legajo,
                "nombre": nombre,
                "apellido": apellido,
                "codigo_sede": "FOR",
                "codigo_materia": "GABD",
                "periodo": periodo,
                "codigo_comision": f"FOR-GABD-{periodo}-{comision}",
                "fecha_solicitud": fecha_solicitud.isoformat(),
                "observaciones": texto(observaciones)
            })

            print(
                f"VALIDA | {solicitud} | "
                f"{legajo} | {nombre} {apellido}"
            )

        # guardo los resultados separados para revisar antes de importar
        SALIDA.mkdir(exist_ok=True)

        for nombre_archivo, datos in [
            ("formosa_validas.json", validas),
            ("formosa_pendientes.json", pendientes)
        ]:
            ruta = SALIDA / nombre_archivo
            ruta.write_text(
                json.dumps(datos, ensure_ascii=False, indent=2),
                encoding="utf-8"
            )

        print(f"\nSolicitudes leídas: {len(filas)}")
        print(f"Válidas en la revisión del archivo: {len(validas)}")
        print(f"Pendientes: {len(pendientes)}")
        print("Resultados guardados en la carpeta resultados.")
        print("Todavía no se realizaron cambios en PostgreSQL.")

    # Cerramos el libro incluso si la lectura o la escritura termina con un error.
    finally:
        libro.close()


if __name__ == "__main__":
    main()