"""Read-only checks against the live customer API; never creates test orders."""
import concurrent.futures
import json
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

BASE = 'https://admin.khidmaplus.com/api/v1/'
ROOT = Path(__file__).resolve().parent.parent
FIXTURES = ROOT / 'test/fixtures/live_customer'
FIXTURES.mkdir(parents=True, exist_ok=True)
RESULTS = []


def request(endpoint, data=None, method='POST', language='en'):
    body = urllib.parse.urlencode(data or {}).encode() if method == 'POST' else None
    req = urllib.request.Request(BASE + endpoint, body,
                                 {'Content-Language': language}, method=method)
    started = time.monotonic()
    try:
        with urllib.request.urlopen(req, timeout=25) as response:
            return response.status, json.load(response), round(time.monotonic()-started, 3)
    except urllib.error.HTTPError as error:
        return error.code, json.loads(error.read()), round(time.monotonic()-started, 3)


def check(name, endpoint, data=None, method='POST', fixture=None, protected=False, language='en'):
    try:
        status, payload, elapsed = request(endpoint, data, method, language)
        if protected:
            assert status in (401, 403), f'Guest unexpectedly received HTTP {status}'
        else:
            assert status == 200 and payload.get('error') is False, str(payload.get('message'))
        if fixture:
            (FIXTURES / (fixture + '.json')).write_text(
                json.dumps(payload, ensure_ascii=False, indent=2), encoding='utf-8')
        result = dict(name=name, passed=True, seconds=elapsed)
        if endpoint == 'get_home_screen_data':
            sections = payload['data']['featured_sections']
            result['sections'] = [{'type': s['section_type'], 'counts': {
                key: len(s[key]) for key in ('categories', 'services', 'providers') if key in s}}
                for s in sections]
            assert all(any(s['section_type'] == kind for s in sections)
                       for kind in ('all_categories','recommended_service','near_by_provider'))
        if endpoint == 'get_country_settings':
            assert payload['data']['currency'] == 'AED', 'Unexpected country currency'
        return result
    except Exception as error:
        return dict(name=name, passed=False, error=str(error))


location = {'latitude': '25.2048', 'longitude': '55.2708'}
jobs = []
for city, lat, lng in [('dubai',25.2048,55.2708),('sharjah',25.3463,55.4209),
                       ('abu_dhabi',24.4539,54.3773),('al_ain',24.2075,55.7447),
                       ('rak',25.7895,55.9432),('fujairah',25.1288,56.3265)]:
    jobs.append(dict(name='Home '+city, endpoint='get_home_screen_data',
                     data={'platform':'app','latitude':lat,'longitude':lng}, fixture='home_'+city))
jobs += [
    dict(name='Country and AED',endpoint='get_country_settings',data=location,fixture='country'),
    dict(name='Provider discovery',endpoint='get_all_providers',data=location,fixture='providers'),
    dict(name='Provider detail',endpoint='get_provider_details',data={**location,'partner_id':118},fixture='provider_detail'),
    dict(name='Service discovery',endpoint='get_all_services',data=location,fixture='services'),
    dict(name='Service detail',endpoint='get_service_details',data={**location,'id':74},fixture='service_detail'),
    dict(name='Provider search',endpoint='search_services_providers',data={**location,'search':'Khidma','type':'provider','limit':10,'offset':0}),
    dict(name='Service search',endpoint='get_all_services',data={**location,'search':'cleaning'}),
    dict(name='Arabic home',endpoint='get_home_screen_data',data={**location,'platform':'app'},language='ar',fixture='home_ar'),
    dict(name='Theme',endpoint='get_theme_colors',method='GET'),
    dict(name='Languages',endpoint='get_language_list?platform=customer_app',method='GET'),
    dict(name='English translations',endpoint='get_language_json_data',data={'language_code':'en','platform':'customer_app'}),
    dict(name='Arabic translations',endpoint='get_language_json_data',data={'language_code':'ar','platform':'customer_app'}),
]
for endpoint in ('get_cart','get_address','get_all_bookings'):
    jobs.append(dict(name='Guest access blocked: '+endpoint,endpoint=endpoint,protected=True))
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    RESULTS = list(pool.map(lambda job: check(**job), jobs))
report = ROOT / 'docs/customer_api_test_results.json'
report.write_text(json.dumps(RESULTS,indent=2),encoding='utf-8')
for result in RESULTS:
    print(('PASS ' if result['passed'] else 'FAIL ')+result['name']+
          (': '+result['error'] if not result['passed'] else ''))
print(f'{sum(r["passed"] for r in RESULTS)}/{len(RESULTS)} passed; report: {report}')
raise SystemExit(0 if all(r['passed'] for r in RESULTS) else 1)
