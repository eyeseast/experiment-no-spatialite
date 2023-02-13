import sqlite3
import shapely
from datasette import hookimpl


@hookimpl
def prepare_connection(conn: sqlite3.Connection):
    conn.create_function("contains", 2, contains, deterministic=True)
    conn.create_function("within", 2, within, deterministic=True)
    conn.create_function("centroid", 1, centroid, deterministic=True)
    conn.create_function("point", 2, point, deterministic=True)


# predicates
def contains(a: str, b: str) -> bool:
    a = shapely.from_geojson(a)
    b = shapely.from_geojson(b)

    return a.contains(b)


def within(a: str, b: str) -> bool:
    a = shapely.from_geojson(a)
    b = shapely.from_geojson(b)

    return a.within(b)


# constructive operations
def centroid(geom: str) -> str:
    geom = shapely.from_geojson(geom)
    point = shapely.centroid(geom)
    return shapely.to_geojson(point)


def point(x: float, y: float) -> str:
    p = shapely.Point(x, y)
    return shapely.to_geojson(p)
