from pathlib import Path
from datetime import date
from collections import Counter
import json
import re
import unicodedata


RAIZ = Path(__file__).resolve().parent.parent
ARCHIVO = RAIZ / "datos" / "reportes_posadas.txt"
SALIDA = RAIZ / "resultados"


def normalizar(texto):
    # quito acentos y unifico mayúsculas para comparar
    contenido = unicodedata.normalize("NFD", texto)
    return "".join(
        letra for letra in contenido
        if unicodedata.category(letra) != "Mn"
    ).upper()


def extraer_unico(patron, texto):
    # si aparecen valores diferentes, no elijo uno por suposición
    encontrados = {
        valor.strip()
        for valor in re.findall(patron, texto, flags=re.IGNORECASE)
    }
    return encontrados.pop() if len(encontrados) == 1 else None


def main():
    contenido = ARCHIVO.read_text(encoding="utf-8-sig")

    # separo los reportes por sus encabezados
    bloques = re.split(r"(?m)^Reporte\s+", contenido)[1:]

    if not bloques:
        raise ValueError("No se encontraron reportes en el archivo.")

    codigos = [
        extraer_unico(r"^(POS-REP-\d+)\b", bloque)
        for bloque in bloques
    ]
    repeticiones = Counter(codigos)

    validas = []
    pendientes = []

    meses = {
        "enero": 1, "febrero": 2, "marzo": 3,
        "abril": 4, "mayo": 5, "junio": 6,
        "julio": 7, "agosto": 8, "septiembre": 9,
        "octubre": 10, "noviembre": 11, "diciembre": 12
    }

    for bloque, codigo in zip(bloques, codigos):
        errores = []
        encabezado, _, cuerpo = bloque.partition("\n")

        if not codigo or repeticiones[codigo] > 1:
            errores.append("Identificador ausente o repetido")

        legajo = extraer_unico(r"\b(POS-\d+)\b", cuerpo)
        periodo = extraer_unico(r"\b(20\d{2}-[12])\b", cuerpo)
        comision = extraer_unico(r"comisi[oó]n\s+([A-Z])\b", cuerpo)

        # reconozco las formas de presentación usadas en estos reportes
        patrones_nombre = [
            r"local,\s*([^,\n]+),\s*legajo",
            r"pedido de inscripción de\s+([^.\n]+)\.",
            r"^\s*([^,\n]+),\s*cuyo legajo",
            r"^\s*([^,\n]+?)\s+solicitó anotarse"
        ]

        nombres = set()
        for patron in patrones_nombre:
            nombres.update(
                coincidencia.strip()
                for coincidencia in re.findall(
                    patron, cuerpo, flags=re.IGNORECASE
                )
            )

        nombre = apellido = None
        if len(nombres) == 1:
            partes = nombres.pop().split()

            # los datos ficticios usan un nombre y un apellido
            # otros casos requieren revisión para no dividirlos mal
            if len(partes) == 2:
                nombre, apellido = partes

        if not nombre or not apellido:
            errores.append("No se pudo identificar nombre y apellido")

        if not legajo:
            errores.append("Legajo ausente o ambiguo")

        if periodo != "2026-2":
            errores.append("Período ausente, ambiguo o no previsto")

        if not comision or comision.upper() != "A":
            errores.append("Comisión ausente, ambigua o no prevista")

        cuerpo_normalizado = normalizar(cuerpo)

        if not re.search(
            r"\bGABD\b|GESTION AVANZADA DE BASES DE DATOS",
            cuerpo_normalizado
        ):
            errores.append("No se reconoció la materia GABD")

        if "POSADAS" not in cuerpo_normalizado:
            errores.append("No se reconoció la sede Posadas")

        fecha_solicitud = None
        fecha_encontrada = re.search(
            r"(\d{1,2}) de ([a-z]+) de (\d{4})",
            encabezado,
            flags=re.IGNORECASE
        )

        if fecha_encontrada:
            dia, mes, anio = fecha_encontrada.groups()
            try:
                fecha_solicitud = date(
                    int(anio), meses[mes.lower()], int(dia)
                ).isoformat()
            except (ValueError, KeyError):
                pass

        if not fecha_solicitud:
            errores.append("Fecha del reporte inválida o ausente")

        if errores:
            pendientes.append({
                "solicitud": codigo,
                "motivos": errores,
                "texto_original": "Reporte " + bloque.strip()
            })
            print(
                f"PENDIENTE | {codigo or 'sin código'} | "
                f"{'; '.join(errores)}"
            )
            continue

        validas.append({
            "solicitud": codigo,
            "legajo": legajo.upper(),
            "nombre": nombre,
            "apellido": apellido,
            "codigo_sede": "POS",
            "codigo_materia": "GABD",
            "periodo": periodo,
            "codigo_comision": f"POS-GABD-{periodo}-A",
            "fecha_solicitud": fecha_solicitud,
            "texto_original": "Reporte " + bloque.strip()
        })

        print(
            f"VALIDA | {codigo} | "
            f"{legajo.upper()} | {nombre} {apellido}"
        )

    SALIDA.mkdir(exist_ok=True)

    for nombre_archivo, datos in [
        ("posadas_validas.json", validas),
        ("posadas_pendientes.json", pendientes)
    ]:
        (SALIDA / nombre_archivo).write_text(
            json.dumps(datos, ensure_ascii=False, indent=2),
            encoding="utf-8"
        )

    print(f"\nReportes leídos: {len(bloques)}")
    print(f"Válidos en la revisión del archivo: {len(validas)}")
    print(f"Pendientes: {len(pendientes)}")
    print("Todavía no se realizaron cambios en PostgreSQL.")


if __name__ == "__main__":
    main()