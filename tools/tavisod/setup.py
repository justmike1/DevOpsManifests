from setuptools import setup

setup(
    name='tavisod',
    packages=["tavisod"],
    version='1.0.4',
    author='Mike',
    author_email='mikej@antidotehealth.com',
    description='google cloud secret manager fetcher for micro services',
    install_requires=['google-cloud-secret-manager==2.12.6', 'google-crc32c==1.5.0']
)
