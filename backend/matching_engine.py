# Put these imports near the top of your matching file
from sentence_transformers import SentenceTransformer, util
from geopy.distance import geodesic
from PIL import Image
import requests
import torch
import traceback

model = SentenceTransformer("clip-ViT-B-32")

def _get_image_urls_from_pet(pet):
    """
    Return a list of image URLs for a pet, respecting multiple field names.
    Always returns a list (possibly empty).
    """
    urls = []
    if not pet:
        return urls
    # Common possible fields
    if isinstance(pet.get("photoUrls"), (list, tuple)):
        urls.extend([u for u in pet.get("photoUrls") if u])
    # single-field alternative
    single = pet.get("image_url") or pet.get("imageUrl") or pet.get("photoUrl")
    if single:
        # if that's a comma-separated string, split defensively
        if isinstance(single, str) and "," in single and not single.strip().startswith("http"):
            # rare case: comma-separated
            urls.extend([s.strip() for s in single.split(",") if s.strip()])
        else:
            urls.append(single)
    # dedupe while preserving order
    seen = set()
    out = []
    for u in urls:
        if u and u not in seen:
            seen.add(u)
            out.append(u)
    return out

def get_image_features(image_urls):
    """
    Accepts a list of image URLs, returns a single torch tensor (embedding) or None.
    Average over all successfully fetched images.
    """
    embeddings = []
    for url in image_urls:
        try:
            resp = requests.get(url, stream=True, timeout=6)
            resp.raise_for_status()
            img = Image.open(resp.raw).convert("RGB")
            emb = model.encode(img, convert_to_tensor=True)  # returns torch.Tensor
            if emb is not None:
                # ensure 1-D float tensor
                embeddings.append(emb.detach().cpu().float())
        except Exception as e:
            print(f"[get_image_features] failed to fetch/encode {url}: {e}")
            # optionally print traceback for deeper debugging:
            # traceback.print_exc()
    if not embeddings:
        return None
    if len(embeddings) == 1:
        return embeddings[0]
    return torch.mean(torch.stack(embeddings), dim=0)

def get_text_features(pet):
    """
    Build a compact descriptive text and return an embedding tensor.
    """
    color = (pet.get("color") or "").strip()
    breed = (pet.get("breed") or "").strip()
    desc = (pet.get("description") or pet.get("notes") or "").strip()
    # include name/tag if present
    name = (pet.get("name") or pet.get("petName") or "").strip()
    pieces = [p for p in [name, color, breed, desc] if p]
    text = " ".join(pieces) if pieces else "unknown pet"
    return model.encode(text, convert_to_tensor=True)

def _safe_cos_sim(a, b):
    """
    Return scalar cosine similarity in [-1,1]. If either is None, return None.
    """
    if a is None or b is None:
        return None
    sim = util.cos_sim(a, b)
    # cos_sim returns a tensor (1x1) or scalar tensor; convert safely
    if hasattr(sim, "item"):
        return float(sim.item())
    try:
        return float(sim.squeeze().cpu().numpy())
    except:
        return None

from sentence_transformers import util
from PIL import Image
import requests
import torch
from geopy.distance import geodesic

def _get_image_urls_from_pet(pet):
    urls = []
    if not pet:
        return urls
    if isinstance(pet.get("photoUrls"), (list, tuple)):
        urls.extend([u for u in pet.get("photoUrls") if u])
    single = pet.get("image_url") or pet.get("imageUrl") or pet.get("photoUrl")
    if single:
        urls.append(single)
    return urls

def get_image_features(image_urls):
    embeddings = []
    for url in image_urls:
        try:
            resp = requests.get(url, stream=True, timeout=5)
            resp.raise_for_status()
            img = Image.open(resp.raw).convert("RGB")
            emb = model.encode(img, convert_to_tensor=True)
            embeddings.append(emb.detach().cpu().float())
        except Exception as e:
            print(f"[get_image_features] failed {url}: {e}")
    if not embeddings:
        return None
    if len(embeddings) == 1:
        return embeddings[0]
    return torch.mean(torch.stack(embeddings), dim=0)

def _safe_cos_sim(a, b):
    if a is None or b is None:
        return None
    sim = util.cos_sim(a, b)
    return float(sim.item())

def match_score(lost_pet, found_pet):
    try:
        # --- image similarity ---
        lost_urls = _get_image_urls_from_pet(lost_pet)
        found_urls = _get_image_urls_from_pet(found_pet)
        lost_emb = get_image_features(lost_urls)
        found_emb = get_image_features(found_urls)
        image_sim = _safe_cos_sim(lost_emb, found_emb) or 0.0

        # --- text similarity (breed only) ---
        breed_match = (lost_pet.get("breed") == found_pet.get("breed"))

        # --- strict rules ---
        if image_sim < 0.85:
            return 0.0
        if not breed_match:
            return 0.0

        # --- optional location score ---
        loc_score = 0.0
        try:
            lost_lat, lost_lon = lost_pet.get("latitude"), lost_pet.get("longitude")
            found_lat, found_lon = found_pet.get("latitude"), found_pet.get("longitude")
            if None not in (lost_lat, lost_lon, found_lat, found_lon):
                dist = geodesic((float(lost_lat), float(lost_lon)),
                                (float(found_lat), float(found_lon))).km
                loc_score = max(0, 1 - dist / 50)
        except:
            pass

        # final weighted score
        final = (0.7 * image_sim) + (0.2 * (1.0 if breed_match else 0.0)) + (0.1 * loc_score)
        return round(final, 3)

    except Exception as e:
        print("[match_score] error:", e)
        return 0.0
