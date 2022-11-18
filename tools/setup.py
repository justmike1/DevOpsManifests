from setuptools import setup

setup(
    name='tavisod',
    version='1.0.2',
    author='Mike',
    author_email='mikej@antidotehealth.com',
    description='google cloud secret manager fetcher for micro services',
    packages=["tavisod"],
    install_requires=['google-cloud-secret-manager==2.12.6']
)
