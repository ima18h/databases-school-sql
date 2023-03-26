import psycopg2


user = 'somedude'
pwd = 'mypassword'

connection = \
    "dbname='" + user + "' " + \
    "user='" + user + "_priv' " + \
    "port='5432' " + \
    "host='dbpg-ifi-kurs03.uio.no' " + \
    "password='" + pwd + "'"


def huffsa():
    conn = psycopg2.connect(connection)

    ch = 0
    while ch != 3:
        print("--[ HUFFSA ]--")
        print("Vennligst velg et alternativ:\n 1. Søk etter planet\n 2. Legg inn forsøksresultat\n 3. Avslutt")
        ch = int(input("Valg: "))
        print()

        if ch == 1:
            print("-- SØK BASERT PÅ MOLEKYL --")
            molekyl1 = input("Molekyl: ")
            molekyl2 = input("Molekyl 2?: ")
            planet_sok(conn, molekyl1, molekyl2)
        elif ch == 2:
            print("-- LEGGER INN FORSØKSRESULTAT --")
            planet_navn = input("Planet: ")
            skummel = input("Skummel?: ")
            while skummel != "j" and skummel != "n":
                skummel = input("Skummel må være n eller j. oppgi j/n: ")
            if skummel == "j":
                skummel = True
            else:
                skummel = False
            intelligent = input("Intelligent?: ")
            while intelligent != "j" and intelligent != "n":
                intelligent = input("intelligent må være n eller j. oppgi j/n: ")
            if intelligent == "j":
                intelligent = True
            else:
                intelligent = False
            beskrivelse = input("Beskrivelse: ")
            legg_inn_resultat(conn, planet_navn, skummel, intelligent, beskrivelse)


def planet_sok(conn, m1: str, m2: str):
    # print the info of all planets that have the given molecule(s) in their materie table
    cur = conn.cursor()
    if m2 == "":
        cur.execute("""SELECT p.navn, p.masse, p.liv, s.avstand, s.masse FROM planet p 
        JOIN materie m ON p.navn = m.planet JOIN stjerne s ON p.stjerne = s.navn 
        WHERE m.molekyl = %s ORDER BY s.avstand;""", (m1,))
    elif m1 == "":
        cur.execute("""SELECT p.navn, p.masse, p.liv, s.avstand, s.masse FROM planet p 
        JOIN materie m ON p.navn = m.planet JOIN stjerne s ON p.stjerne = s.navn 
        WHERE m.molekyl = %s ORDER BY s.avstand;""", (m2,))
    else:
        cur.execute("""SELECT p.navn, p.masse, p.liv, s.avstand, s.masse FROM planet p 
        JOIN materie m ON p.navn = m.planet JOIN materie m2 ON p.navn = m2.planet JOIN stjerne s ON p.stjerne = s.navn 
        WHERE m.molekyl = %s AND m2.molekyl = %s ORDER BY s.avstand;""", (m1, m2))
    rows = cur.fetchall()
    if not rows:
        print("Fant ingen planeter med disse molekylene.")
        return None

    for i, row in enumerate(rows, start=1):
        print(f"Planet {i}, {row[0]}")
        print(f"Massen er {row[1]}")
        print(f"Har liv: {row[2]}")
        print(f"Avstanden til stjernen er {row[3]}")
        print(f"Stjernens masse er {row[4]}")
        print()


def legg_inn_resultat(conn, plnt: str, skml, intl, bskr: str):
    cur = conn.cursor()
    cur.execute("""UPDATE planet SET skummel = %s, intelligent = %s, beskrivelse = %s WHERE navn = %s;""",
                (skml, intl, bskr, plnt))
    conn.commit()
    print("Resultatet ble lagt inn.")
    print()


if __name__ == "__main__":
    huffsa()
