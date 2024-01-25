import requests

def uruchom_proces_fme_flow(webhook_url):
    try:
        # Wysyłamy żądanie HTTP POST z pustym ciałem
        response = requests.post(webhook_url, data={})

        # Sprawdzamy, czy żądanie zostało pomyślnie wykonane (kod odpowiedzi 200)
        if response.status_code == 200:
            print("Proces FME Flow został pomyślnie uruchomiony.")
        else:
            print(f"Błąd podczas uruchamiania procesu. Kod odpowiedzi: {response.status_code}")
    except Exception as e:
        print(f"Wystąpił błąd: {str(e)}")

#webhook
webhook = "http://DESKTOP-Q5AQFVB/fmejobsubmitter/Dashboards/z12v5.fmw?haslo=&powiat=powiat%20inowroc%C5%82awski&e-mail_klient=ciegoturap%40gmail.com&cloud_coverage=18&data_pocz%C4%85tkowa=20230704000000&data_ko%C5%84cowa=20230714000000&e-mail=ciegoturap%40gmail.com&SourceDataset_GEOTIFF_3=C%3A%5CUsers%5Cciego%5CDesktop%5C5_semestr%5CBazy_dnanych_przestrzennych%5Czaj10%5C2023-05-10-00_00_2023-05-10-23_59_Sentinel-2_L2A_B04_(Raw).tiff&SourceDataset_GEOTIFF=C%3A%5CUsers%5Cciego%5CDesktop%5C5_semestr%5CBazy_dnanych_przestrzennych%5Czaj10%5C2023-05-10-00_00_2023-05-10-23_59_Sentinel-2_L2A_B08_(Raw).tiff&SourceDataset_SHAPEFILE=C%3A%5CUsers%5Cciego%5CDesktop%5C5_semestr%5CBazy_dnanych_przestrzennych%5Czaj10%5Cpowiaty.shp&DestDataset_GEOTIFF=C%3A%5CUsers%5Cciego%5CDesktop%5C5_semestr%5CBazy_dnanych_przestrzennych%5Czaj12%5Cndvi&opt_showresult=false&opt_servicemode=sync&token=5ca4ed4efc4cd0669b90df3945b920ca73abefca"


uruchom_proces_fme_flow(webhook)
