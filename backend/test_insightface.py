from insightface.app import FaceAnalysis

print("Initializing FaceAnalysis...")
app = FaceAnalysis(name="buffalo_l", allowed_modules=['detection', 'recognition'])
app.prepare(ctx_id=0, det_size=(320, 320))
print("Successfully initialized with limited modules!")
