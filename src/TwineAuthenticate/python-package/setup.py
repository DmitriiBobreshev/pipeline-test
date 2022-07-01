from setuptools import setup
import datetime
minor = datetime.datetime.now().strftime("%y%m%d")
patch = datetime.datetime.now().strftime("%H%M%f")
setup(
    name='twineAuthenticate-twineauthenticate-publishtest',
    version='1.' + minor + '.' + patch,
    author='smd',
    author_email='example@example.com',
    description='This is the summary (or short description)',
    long_description='This is the long description, which can be in the following formats: text/plain, text/markdown, or text/x-rst',
    long_description_content_type='text/markdown; charset=UTF-8; variant=GFM',
    python_requires='>2.9',
    packages=['greetings'],
    classifiers=(
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent"
    ),
    keywords='sample test blah',
    install_requires="sampleproject > 1.0"
)